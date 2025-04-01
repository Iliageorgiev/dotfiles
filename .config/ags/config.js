import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import Gtk from 'gi://Gtk';
import Cairo from 'gi://cairo';
import { MediaWidget, MediaButton, mprisVisible, volumeWidget, microphoneWidget } from "./Media.js";
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import Gdk from 'gi://Gdk';
import { PowerMenu } from './PowerMenu.js';

// Import the system tray service
const systemtray = await Service.import('systemtray');

// Debounce function
const debounce = (func, wait) => {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => func(...args), wait);
    };
};

// Clock widget with calendar tooltip
const Clock = () => {
    const timeLabel = Widget.Label({
        class_name: 'clock',
    });

    const calendarLabel = Widget.Label({
        class_name: 'calendar-label',
        justification: 'left',
        use_markup: true,
    });

    const createMonthCalendar = (year, month, currentDay, isCurrentMonth) => {
        const date = GLib.DateTime.new_local(year, month, 1, 0, 0, 0);
        let calendarStr = `<b>${date.format('%B %Y')}</b>\n`;
        calendarStr += '<span font_family="monospace">Mo Tu We Th Fr Sa Su</span>\n';
        
        const daysInMonth = new Date(year, month, 0).getDate();
        const firstDay = new Date(year, month - 1, 1).getDay();
        const firstDayAdjusted = (firstDay + 6) % 7; // Adjust so Monday is 0
        
        let dayCount = 1;
        for (let week = 0; week < 6; week++) {
            let weekStr = '<span font_family="monospace">';
            for (let weekday = 0; weekday < 7; weekday++) {
                if ((week === 0 && weekday < firstDayAdjusted) || dayCount > daysInMonth) {
                    weekStr += '   ';
                } else {
                    const dayStr = dayCount.toString().padStart(2);
                    if (dayCount === currentDay && isCurrentMonth) {
                        weekStr += `<span foreground='#00FF00'>${dayStr}</span> `;
                    } else {
                        weekStr += `${dayStr} `;
                    }
                    dayCount++;
                }
            }
            weekStr += '</span>\n';
            calendarStr += weekStr;
            if (dayCount > daysInMonth) break;
        }
        
        calendarStr += '\n';
        return calendarStr;
    };

    const updateCalendar = () => {
        const now = GLib.DateTime.new_now_local();
        const year = now.get_year();
        const currentMonth = now.get_month();
        const currentDay = now.get_day_of_month();
        
        let calendarStr = '';
        
        // Current month
        calendarStr += createMonthCalendar(year, currentMonth, currentDay, true);
        
        // Future months (next 5 months)
        for (let i = 1; i <= 5; i++) {
            let futureMonth = currentMonth + i;
            let futureYear = year;
            if (futureMonth > 12) {
                futureMonth -= 12;
                futureYear += 1;
            }
            calendarStr += createMonthCalendar(futureYear, futureMonth, currentDay, false);
        }
        
        calendarLabel.label = calendarStr;
    };

    const tooltipWindow = Widget.Window({
        name: 'calendar-tooltip',
        layer: 'overlay',
        anchor: ['top'],
        visible: false,
        child: Widget.Box({
            vertical: true,
            children: [
                Widget.Label({
                    class_name: 'calendar-tooltip-title',
                    label: 'Calendar',
                }),
                Widget.Scrollable({
                    child: calendarLabel,
                    vscroll: 'always',
                    hscroll: 'never',
                    height_request: 300,
                    width_request: 220,
                }),
            ],
        }),
    });

    const updateClock = () => {
        const now = GLib.DateTime.new_now_local();
        timeLabel.label = now.format('%H:%M:%S');
    };

    const toggleTooltip = () => {
        tooltipWindow.visible = !tooltipWindow.visible;
        if (tooltipWindow.visible) {
            updateCalendar();
        }
    };

    const widget = Widget.Button({
        child: timeLabel,
        on_clicked: toggleTooltip,
        setup: self => {
            self.poll(1000, updateClock);
            self.connect('destroy', () => {
                tooltipWindow.visible = false;
            });
        },
    });

    App.addWindow(tooltipWindow);

    return widget;
};

// Function to get the icon for a window class
const getIconForClass = (windowClass) => {
    if (!windowClass) return 'application-x-executable'; // Fallback icon if no class

    const iconTheme = Gtk.IconTheme.get_default();
    const possibleNames = [
        windowClass.toLowerCase(),
        windowClass.toLowerCase().replace(/\s/g, '-'),
        windowClass.toLowerCase().replace(/\s/g, ''),
    ];

    for (const name of possibleNames) {
        if (iconTheme.has_icon(name)) {
            return name;
        }
    }

    return 'application-x-executable'; // Fallback icon
};

// List of applications to ignore
const ignoredApps = ['GLava', 'mpvpaper'];

const updateWorkspaceButton = (button) => {
    const workspaceId = button.workspace;
    const clients = Hyprland.clients.filter(client => client.workspace.id === workspaceId);
    const activeClients = clients.filter(client => !ignoredApps.includes(client.class));
    
    let content;
    let currentIcon;
    if (activeClients.length > 0) {
        currentIcon = getIconForClass(activeClients[0].class);
        content = Widget.Icon({ icon: currentIcon, size: 16 });
    } else {
        currentIcon = 'number';
        content = Widget.Label({ label: `${workspaceId}` });
    }
    
    button.child.children = [Widget.Box({ class_name: 'workspace-content', children: [content] })];
    
    const isActive = Hyprland.active.workspace.id === workspaceId;
    
    // Remove previous animation classes
    button.toggleClassName('animating', false);
    button.toggleClassName('activating', false);
    button.toggleClassName('deactivating', false);
    
    // Apply new classes for animation
    if (isActive && !button.lastActive) {
        button.toggleClassName('animating', true);
        button.toggleClassName('activating', true);
    } else if (!isActive && button.lastActive) {
        button.toggleClassName('animating', true);
        button.toggleClassName('deactivating', true);
    }
    
    // Toggle active class
    button.toggleClassName('active', isActive);
    
    // Only log if there's a change
    if (button.lastIcon !== currentIcon || button.lastActive !== isActive) {
        button.lastIcon = currentIcon;
        button.lastActive = isActive;
    }
    
    // Remove animation classes after animation completes
    if (button.toggleClassName('animating', true)) {
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
            button.toggleClassName('animating', false);
            button.toggleClassName('activating', false);
            button.toggleClassName('deactivating', false);
            return GLib.SOURCE_REMOVE;
        });
    }
};

const Workspaces = () => {
    const workspaceButtons = Array.from({ length: 5 }, (_, i) => i + 1).map(i => 
        Widget.Button({
            class_name: 'workspace-button',
            class_name: 'workspace-button',  // Add this line to ensure the class is applied
            setup: self => {
                self.workspace = i;
                self.lastActive = false;
                updateWorkspaceButton(self);
            },
            on_clicked: () => Utils.exec(`hyprctl dispatch workspace ${i}`),
            child: Widget.Box({}),
        })
    );

    // Update all workspaces when active workspace changes
    Hyprland.active.workspace.connect('changed', () => {
        workspaceButtons.forEach(updateWorkspaceButton);
    });

    // Update when clients change
    Hyprland.connect('client-added', () => workspaceButtons.forEach(updateWorkspaceButton));
    Hyprland.connect('client-removed', () => workspaceButtons.forEach(updateWorkspaceButton));

    return Widget.Box({
        class_name: 'workspaces',
        children: workspaceButtons,
        setup: self => {
            // Background poll every 5 seconds for any missed updates
            self.poll(5000, () => workspaceButtons.forEach(updateWorkspaceButton));
        },
    });
};

// Function to open btop in fullscreen
const openBtop = () => Utils.execAsync(['kitty', '--start-as=fullscreen', '--title', 'btop', 'sh', '-c', 'btop']);

// Combined CPU Usage and Temperature Widget
const CpuWidget = () => {
    const tempPaths = [
        
        "/sys/class/thermal/thermal_zone0/temp"
    ];

    const readTemp = () => {
        for (const path of tempPaths) {
            try {
                const temp = parseInt(Utils.readFile(path)) / 1000;
                return temp;
            } catch (error) {
                // Error reading temperature
            }
        }
        return null;
    };

    const cpuBox = Widget.Box({
        class_name: 'cpu-box',
        vertical: true,
        spacing: 1,
        vpack: 'center',
    });

    const getColor = (usage) => {
        if (usage < 50) return '#00BFFF'; // DeepSkyBlue
        if (usage < 80) return '#FFD700'; // Gold
        return '#FF0000'; // Red
    };

    const updateWidget = () => {
        Utils.execAsync(['bash', '-c', "mpstat -P ALL 1 1 | awk '/^[0-9]/ {print 100 - $13}' | tail -n 4"])
            .then(output => {
                const cpuUsages = output.trim().split('\n').map(Number);
                const temp = readTemp();

                cpuBox.children = cpuUsages.map((usage, index) => {
                    return Widget.Box({
                        class_name: 'cpu-core',
                        children: [
                            Widget.Box({
                                class_name: 'cpu-core-usage',
                                css: `background-color: ${getColor(usage)}; min-width: ${usage}px; min-height: 4px;`,
                            }),
                        ],
                    });
                });

                if (temp !== null) {
                    cpuBox.add(Widget.Box({
                        class_name: 'cpu-temp',
                        children: [
                            Widget.Box({
                                class_name: 'cpu-temp-usage',
                                css: `background-color: ${getColor(temp)}; min-width: ${temp}px; min-height: 4px;`,
                            }),
                        ],
                    }));

                    if (temp >= 80) {
                        cpuBox.css = 'animation: blink 1s infinite;';
                    } else {
                        cpuBox.css = '';
                    }
                }

                // Add temperature label
                cpuBox.add(Widget.Label({
                    class_name: 'cpu-temp-label',
                    label: temp !== null ? `${temp.toFixed(1)}°C` : 'N/A',
                }));
            })
            .catch(error => {
                console.error('Error updating CPU widget:', error);
                cpuBox.children = [Widget.Label({ label: 'CPU: N/A' })];
            });
    };

    return Widget.Button({
        class_name: 'cpu-widget',
        child: Widget.Box({
            vertical: true,
            vpack: 'center',
            child: cpuBox,
        }),
        tooltip_text: 'Click to open btop',
        on_clicked: openBtop,
        setup: self => self.poll(2000, updateWidget), // Update every 2 seconds
    });
};

// Memory Usage Widget
const MemoryUsage = () => {
    const circularProgress = Widget.CircularProgress({
        class_name: 'memory-usage',
        start_at: 0.75,
        rounded: false,
        inverted: false,
        value: 0,
    });

    const label = Widget.Label({
        class_name: 'memory-label',
    });

    const updateMemory = () => {
        Utils.execAsync(['bash', '-c', "free -b | awk '/^Mem:/ {print $2, $7}'"])
            .then(output => {
                const [total, available] = output.trim().split(/\s+/).map(Number);
                const used = total - available;
                const percentage = used / total;

                circularProgress.value = percentage;
                label.label = `${(percentage * 100).toFixed(0)}%`;
            })
            .catch(error => {
                console.error('Error updating memory usage:', error);
                label.label = 'N/A';
            });
    };

    const widget = Widget.Box({
        class_name: 'memory-box',
        children: [circularProgress, label],
        setup: self => {
            self.poll(500, updateMemory);
        },
    });

    return widget;
};

// HDD usage widget
const HddUsage = () => {
    const circularProgress = Widget.CircularProgress({
        class_name: 'hdd-usage',
        start_at: 0.75,
        rounded: false,
        inverted: false,
        value: 0,
    });

    const label = Widget.Label({
        class_name: 'hdd-label',
    });

    const updateHdd = () => {
        Utils.execAsync(['bash', '-c', "df -h --output=size,used,avail,pcent / | awk 'NR==2 {print $1, $2, $3, $4}'"])
            .then(usage => {
                const [total, used, avail, percent] = usage.trim().split(/\s+/);
                const usedGiB = parseFloat(used);
                const totalGiB = parseFloat(total);
                const usedPercent = Math.round((usedGiB / totalGiB) * 100);
                
                circularProgress.value = usedPercent / 100;
                label.label = `${usedPercent}%`;
            })
            .catch(error => {
                console.error('Error updating HDD usage:', error);
                label.label = 'N/A';
            });
    };

    const widget = Widget.Box({
        class_name: 'hdd-box',
        children: [circularProgress, label],
        setup: self => {
            self.poll(30000, updateHdd); // Update every 30 seconds
        },
    });

    return widget;
};

// Network Speed Widget
const NetworkSpeed = () => Widget.Box({
    hpack: 'end',
    child: Widget.Label({
        setup: self => {
            self.poll(1000, () => {
                Utils.execAsync(['bash', '-c', "cat /sys/class/net/*/statistics/rx_bytes /sys/class/net/*/statistics/tx_bytes"])
                    .then(data => {
                        const [rxBytes, txBytes] = data.trim().split(/\s+/).map(Number);
                        const rxSpeed = (rxBytes - (self.lastRxBytes || rxBytes)) / 1024;
                        const txSpeed = (txBytes - (self.lastTxBytes || txBytes)) / 1024;
                        self.lastRxBytes = rxBytes;
                        self.lastTxBytes = txBytes;

                        const totalSpeed = rxSpeed + txSpeed;
                        let color;
                        if (totalSpeed < 1000) {
                            color = '#FFFFFF'; // White for 0-1000 KB/s
                        } else if (totalSpeed < 3000) {
                            color = '#FFD700'; // Yellow for 1000-3000 KB/s
                        } else if (totalSpeed < 8000) {
                            color = '#00FF00'; // Green for 3000-8000 KB/s
                        } else if (totalSpeed < 20000) {
                            color = '#FF0000'; // Red for 8000-20000 KB/s
                        } else {
                            color = '#FF0000'; // Red for 20000+ KB/s
                        }

                        self.label = `${rxSpeed.toFixed(1)}KB/s ↓ ${txSpeed.toFixed(1)}KB/s ↑`;
                        self.css = `color: ${color}; min-width: 150px;`;

                        if (totalSpeed >= 20000) {
                            self.css += ' animation: blink 1s infinite;';
                        }
                    })
                    .catch(error => {
                        self.label = 'Network: N/A';
                        self.css = 'color: inherit; min-width: 150px;';
                    });
            });
        },
    }),
});

// System Tray Widget using AGS system tray service
const SysTrayItem = item => Widget.Button({
    child: Widget.Icon().bind('icon', item, 'icon'),
    tooltipMarkup: item.bind('tooltip_markup'),
    onPrimaryClick: (_, event) => item.activate(event),
    onSecondaryClick: (_, event) => item.openMenu(event),
});

const SystemTray = () => Widget.Box({
    children: systemtray.bind('items').as(i => i.map(SysTrayItem))
});

// Weather Widget
const WeatherWidget = () => Widget.Label({
    class_name: 'weather-widget',
    setup: self => self.poll(60000000, () => { // Update every 6000 seconds (60000000 ms)
        Utils.execAsync(['bash', '-c', `curl 'https://wttr.in/Zgorigrad?format=1' | tr -d '+'`])
            .then(weather => {
                self.label = weather.trim();
            })
            .catch(error => {
                self.label = 'Weather: N/A';
            });
    }),
});

let packageUpdateWidget = null;

// Package Update Widget
const PackageUpdateWidget = () => {
    const icon = Widget.Icon({
        icon: 'system-software-update-symbolic',
    });

    const label = Widget.Label({
        class_name: 'package-updates',
    });

    const box = Widget.Box({
        spacing: 5,
        children: [icon, label],
    });

    const tooltipContent = Widget.Label({
        class_name: 'update-tooltip-content',
        justification: 'left',
    });

    let pendingUpdates = [];
    let tooltipWindow = null; // Declare tooltipWindow here

    const updateCount = () => {
        console.log('Checking for updates...');
        Utils.execAsync(['bash', '-c', '(checkupdates; yay -Qua) 2>/dev/null || true'])
            .then(output => {
                console.log('Update check output:', output);
                pendingUpdates = output.trim().split('\n').filter(line => line.length > 0);
                const count = pendingUpdates.length;
                label.label = count > 0 ? `${count}` : '';

                if (count > 0) {
                    tooltipContent.label = pendingUpdates.join('\n');
                    icon.icon = 'system-software-update-symbolic';
                    icon.css = 'color: #FFD700;';
                } else {
                    tooltipContent.label = 'System up to date';
                    icon.icon = 'system-software-update-symbolic';
                    icon.css = 'color: #00FF00;';
                }
            })
            .catch(error => {
                console.error('Error checking for updates:', error);
                label.label = '';
                tooltipContent.label = 'Error checking for updates';
                icon.icon = 'system-software-update-symbolic';
                icon.css = 'color: #FF0000;';
            });
    };

    tooltipWindow = Widget.Window({
        name: 'update-tooltip',
        layer: 'overlay',
        anchor: ['top', 'right'],
        visible: false,
        child: Widget.Box({
            vertical: true,
            children: [
                Widget.Label({
                    class_name: 'update-tooltip-title',
                    label: 'Pending Updates:',
                }),
                tooltipContent,
            ],
        }),
    });

    const showTooltip = () => {
        tooltipWindow.show_all();
    };

    const hideTooltip = () => {
        tooltipWindow.hide();
    };

    const widget = Widget.Button({
        child: box,
        onClicked: () => {
            Utils.execAsync(['kitty', '--class', 'update-floating', 'yay', '-Syu']);
        },
        onSecondaryClick: () => {
            updateCount();
        },
        onHover: showTooltip,
        onHoverLost: hideTooltip,
    });

    // Initial check
    updateCount();

    // Set up a recurring check
    const updateInterval = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 900000, () => {
        updateCount();
        return GLib.SOURCE_CONTINUE;
    });

    const containerBox = Widget.Box({
        spacing: 5,
        children: [widget],
    });

    containerBox.connect('destroy', () => {
        if (updateInterval) {
            GLib.source_remove(updateInterval);
        }
    });

    // Add mouse enter and leave events to handle tooltip visibility
    widget.on('enter-notify-event', showTooltip);
    widget.on('leave-notify-event', hideTooltip);
    tooltipWindow.on('leave-notify-event', hideTooltip);

    return containerBox;
};

// Create the widget
packageUpdateWidget = PackageUpdateWidget();

// Media Widget Window
const MediaWindow = () => Widget.Window({
    name: "mpris",
    anchor: ["top", "right"],
    child: MediaWidget(),
    visible: mprisVisible.bind(),
});

// Keyboard Layout Widget
const KeyboardLayout = () => {
    const label = Widget.Label({
        class_name: 'keyboard-layout',
    });

    const updateLayout = () => {
        Utils.execAsync(['hyprctl', 'devices', '-j'])
            .then(output => {
                const devices = JSON.parse(output);
                const mainKeyboard = devices.keyboards.find(kb => kb.main);
                if (mainKeyboard) {
                    label.label = mainKeyboard.active_keymap.toLowerCase().includes('us') ? '🇺🇸' : '🇧🇬';
                } else {
                    // Fallback to the first keyboard if no main keyboard is found
                    const firstKeyboard = devices.keyboards[0];
                    if (firstKeyboard) {
                        label.label = firstKeyboard.active_keymap.toLowerCase().includes('us') ? '🇺🇸' : '🇧🇬';
                    } else {
                        label.label = '❓';
                    }
                }
            })
            .catch(error => {
                console.error('Error getting keyboard layout:', error);
                label.label = '⚠️';
            });
    };

    const toggleLayout = () => {
        Utils.execAsync(['hyprctl', 'switchxkblayout', 'semico-usb-keyboard', 'next'])
            .then(() => {
                // Wait a short moment for the layout to change before updating
                GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => {
                    updateLayout();
                    return GLib.SOURCE_REMOVE;
                });
            })
            .catch(error => {
                console.error('Error toggling keyboard layout:', error);
            });
    };

    const widget = Widget.Button({
        class_name: 'keyboard-layout-box',
        child: label,
        on_clicked: toggleLayout,
    });

    widget.interval = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
        updateLayout();
        return true; // Returning true keeps the interval running
    });

    updateLayout(); // Initial update

    widget.connect('destroy', () => {
        if (widget.interval) {
            GLib.source_remove(widget.interval);
        }
    });

    return widget;
};

const Ds4BatteryWidget = () => {
    const icon = Widget.Icon({
        icon: 'input-gaming-symbolic',
        size: 16,
        visible: false,
    });

    const label = Widget.Label({
        class_name: 'ds4-battery-label',
        visible: false,
    });

    const updateBattery = () => {
        Utils.execAsync(['bash', '-c', "upower -e | grep -i 'ps_controller'"])
            .then(devicePath => {
                if (!devicePath || devicePath.trim() === '') {
                    icon.visible = false;
                    label.visible = false;
                    return Promise.reject('No controller connected');
                }

                return Utils.execAsync(['upower', '-i', devicePath.trim()])
                    .then(info => {
                        console.log('Controller info:', info); // Debug output
                        const percentage = info.match(/percentage:\s+(\d+)%/)?.[1];
                        const state = info.match(/state:\s+(\w+)/)?.[1];

                        if (percentage) {
                            const batteryLevel = parseInt(percentage);
                            
                            // Update icon based on battery level
                            if (state === 'charging') {
                                icon.icon = 'battery-charging-symbolic';
                            } else if (batteryLevel <= 20) {
                                icon.icon = 'battery-empty-symbolic';
                            } else if (batteryLevel <= 40) {
                                icon.icon = 'battery-low-symbolic';
                            } else if (batteryLevel <= 60) {
                                icon.icon = 'battery-medium-symbolic';
                            } else if (batteryLevel <= 80) {
                                icon.icon = 'battery-good-symbolic';
                            } else {
                                icon.icon = 'battery-full-symbolic';
                            }

                            // Update label
                            label.label = `${batteryLevel}%`;
                            
                            // Show both icon and label
                            icon.visible = true;
                            label.visible = true;

                            // Add warning class if battery is low
                            label.toggleClassName('battery-warning', batteryLevel <= 20);
                        } else {
                            icon.visible = false;
                            label.visible = false;
                        }
                    });
            })
            .catch(error => {
                if (error !== 'No controller connected') {
                    console.debug('DS4 Battery Widget:', error);
                }
                icon.visible = false;
                label.visible = false;
            });
    };

    const widget = Widget.Box({
        class_name: 'ds4-battery-widget',
        spacing: 4,
        children: [icon, label],
        setup: self => {
            // Initial update
            updateBattery();
            // Poll every 5 seconds
            self.poll(5000, updateBattery);
        },
    });

    return widget;
};

const Bar = () => {
    const bar = Widget.CenterBox({
        class_name: 'main-bar',
        start_widget: Widget.Box({
            class_name: 'left-widgets',
            children: [
                Workspaces(),
                CpuWidget(),
                MemoryUsage(),
                HddUsage(), // This should now look similar to MemoryUsage
                NetworkSpeed(),
            ],
        }),
        center_widget: Clock(),
        end_widget: Widget.Box({
            class_name: 'right-widgets',
            hpack: 'end',
            spacing: 5,
            children: [
                KeyboardLayout(),
                packageUpdateWidget,
                WeatherWidget(),
                MediaButton(),
                Ds4BatteryWidget(),
                Widget.Box({
                    spacing: 5,
                    children: [
                        volumeWidget,
                        microphoneWidget,
                        Widget.Box({ 
                            class_name: 'widget-spacer',
                            css: 'background-color: transparent;'
                        }),
                    ],
                }),
                SystemTray(),
            ],
        }),
    });

    let leaveTimeout = null;

    bar.on('enter-notify-event', () => {
        if (leaveTimeout) {
            clearTimeout(leaveTimeout);
            leaveTimeout = null;
        }
    });

    bar.on('leave-notify-event', () => {
        leaveTimeout = setTimeout(() => {
            closeAllTooltips();
        }, 300); // 300ms delay before closing tooltips
    });

    return bar;
};

// Main Window for the bar
const BarWindow = () => Widget.Window({
    name: 'bar',
    anchor: ['top', 'left', 'right'],
    exclusivity: 'exclusive',
    child: Bar(),
});

// Use App.config() instead of default export
App.config({
    style: './style.css',
    windows: [
        BarWindow(),
        MediaWindow(),
        PowerMenu(),
    ],
});

const closeAllTooltips = () => {
    // Close package update tooltip
    if (packageUpdateWidget) packageUpdateWidget.hideTooltip();
    
    // Close volume and microphone tooltips
    if (currentOpenTooltip) {
        currentOpenTooltip.hide();
        currentOpenTooltip = null;
    }
    
    // Close calendar tooltip
    if (tooltipWindow) {
        tooltipWindow.visible = false;
    }
    
    // Add any other tooltips here
};

// Add this to your App.config to ensure the interval is removed when the app is closed
App.connect('config-parsed', () => {
    App.connect('window-toggled', (_, visible) => {
        if (!visible && packageUpdateWidget && packageUpdateWidget.cleanUp) {
            packageUpdateWidget.cleanUp();
        }
    });
});
