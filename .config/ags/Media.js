import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import { execAsync, timeout } from 'resource:///com/github/Aylur/ags/utils.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import GLib from 'gi://GLib';

const mpris = await Service.import("mpris")
const players = mpris.bind("players")

const FALLBACK_ICON = "audio-x-generic-symbolic"
const PLAY_ICON = "media-playback-start-symbolic"
const PAUSE_ICON = "media-playback-pause-symbolic"
const PREV_ICON = "media-skip-backward-symbolic"
const NEXT_ICON = "media-skip-forward-symbolic"

// Update these constants at the top of your file
const MUSIC_PLAY_ICON = "audio-x-generic-symbolic"  // or your preferred icon
const MUSIC_PAUSE_ICON = "audio-x-generic-symbolic" // or your preferred icon

// Create and export the mprisVisible variable
export const mprisVisible = Variable(false)

/** @param {number} length */
function lengthStr(length) {
    const min = Math.floor(length / 60)
    const sec = Math.floor(length % 60)
    const sec0 = sec < 10 ? "0" : ""
    return `${min}:${sec0}${sec}`
}

/** @param {import('types/service/mpris').MprisPlayer} player */
function Player(player) {
    const img = Widget.Box({
        class_name: "img",
        vpack: "start",
        css: player.bind("cover_path").transform(p => `
            background-image: url('${p}');
        `),
    })

    const title = Widget.Label({
        class_name: "title",
        wrap: true,
        hpack: "start",
        label: player.bind("track_title"),
    })

    const artist = Widget.Label({
        class_name: "artist",
        wrap: true,
        hpack: "start",
        label: player.bind("track_artists").transform(a => a.join(", ")),
    })

    const positionSlider = Widget.Slider({
        class_name: "position",
        draw_value: false,
        on_change: ({ value }) => player.position = value * player.length,
        visible: player.bind("length").as(l => l > 0),
        setup: self => {
            function update() {
                const value = player.position / player.length
                self.value = value > 0 ? value : 0
            }
            self.hook(player, update)
            self.hook(player, update, "position")
            self.poll(1000, update)
        },
    })

    const positionLabel = Widget.Label({
        class_name: "position",
        hpack: "start",
        setup: self => {
            const update = (_, time) => {
                self.label = lengthStr(time || player.position)
                self.visible = player.length > 0
            }

            self.hook(player, update, "position")
            self.poll(1000, update)
        },
    })

    const lengthLabel = Widget.Label({
        class_name: "length",
        hpack: "end",
        visible: player.bind("length").transform(l => l > 0),
        label: player.bind("length").transform(lengthStr),
    })

    const icon = Widget.Icon({
        class_name: "icon",
        hexpand: true,
        hpack: "end",
        vpack: "start",
        tooltip_text: player.identity || "",
        icon: player.bind("entry").transform(entry => {
            const name = `${entry}-symbolic`
            return Utils.lookUpIcon(name) ? name : FALLBACK_ICON
        }),
    })

    const playPause = Widget.Button({
        class_name: "play-pause",
        on_clicked: () => player.playPause(),
        visible: player.bind("can_play"),
        child: Widget.Icon({
            icon: player.bind("play_back_status").transform(s => {
                switch (s) {
                    case "Playing": return PAUSE_ICON
                    case "Paused":
                    case "Stopped": return PLAY_ICON
                }
            }),
        }),
    })

    const prev = Widget.Button({
        on_clicked: () => player.previous(),
        visible: player.bind("can_go_prev"),
        child: Widget.Icon(PREV_ICON),
    })

    const next = Widget.Button({
        on_clicked: () => player.next(),
        visible: player.bind("can_go_next"),
        child: Widget.Icon(NEXT_ICON),
    })

    return Widget.Box(
        { class_name: "player" },
        img,
        Widget.Box(
            {
                vertical: true,
                hexpand: true,
            },
            Widget.Box([
                title,
                icon,
            ]),
            artist,
            Widget.Box({ vexpand: true }),
            positionSlider,
            Widget.CenterBox({
                start_widget: positionLabel,
                center_widget: Widget.Box([
                    prev,
                    playPause,
                    next,
                ]),
                end_widget: lengthLabel,
            }),
        ),
    )
}

export function MediaWidget() {
    return Widget.Box({
        vertical: true,
        css: "min-height: 2px; min-width: 2px;",
        visible: mprisVisible.bind(),
        children: mpris.bind('players').transform(p => p.map(Player)),
    });
}

export function MediaButton() {
    const icon = Widget.Icon();

    const updateIcon = () => {
        if (mprisVisible.value) {
            icon.icon = MUSIC_PAUSE_ICON;
        } else {
            const playing = mpris.players.some(player => player.playBackStatus === "Playing");
            icon.icon = playing ? MUSIC_PAUSE_ICON : MUSIC_PLAY_ICON;
        }
    };

    return Widget.Button({
        class_name: 'media-button',
        child: icon,
        visible: mpris.bind('players').transform(p => p.length > 0),
        onClicked: () => {
            mprisVisible.value = !mprisVisible.value;
            updateIcon();
        },
        setup: self => {
            updateIcon();
            self.poll(1000, updateIcon);
        },
    });
}

// Helper function to create a debounced hide function
const createDebouncedHide = (popupVisible) => {
    let timer = null;
    return () => {
        if (timer) {
            clearTimeout(timer);
        }
        timer = timeout(5000, () => {
            popupVisible.value = false;
        });
    };
};

// Volume Widget
export const VolumeWidget = () => {
    const slider = Widget.Slider({
        class_name: 'volume-slider',
        vertical: true,
        inverted: true,
        hexpand: false,
        vexpand: true,
        drawValue: false,
        onChange: ({ value }) => {
            Audio.speaker.volume = isFinite(value) ? value : 0;
        },
        setup: self => self.hook(Audio.speaker, () => {
            self.value = isFinite(Audio.speaker.volume) ? Audio.speaker.volume : 0;
        }),
    });

    const volumeLabel = Widget.Label({
        class_name: 'volume-popup-label',
        css: 'min-width: 130px;', // Set a fixed minimum width
    });

    const popupContent = Widget.Box({
        vertical: true,
        css: 'padding: 5px;',
        children: [
            volumeLabel,
            slider,
        ],
    });

    const popup = Widget.Window({
        name: 'volume-popup',
        child: popupContent,
        anchor: ['top', 'right'],
        visible: false,
    });

    const icon = Widget.Icon({
        icon: 'audio-volume-muted-symbolic',
    });

    const button = Widget.Button({
        child: icon,
        onClicked: () => {
            Audio.speaker.isMuted = !Audio.speaker.isMuted;
        },
        onSecondaryClick: () => Utils.execAsync('pavucontrol'),
        onScrollUp: () => {
            Audio.speaker.volume += 0.05;
            Audio.speaker.isMuted = false;
        },
        onScrollDown: () => {
            Audio.speaker.volume -= 0.05;
            Audio.speaker.isMuted = false;
        },
        setup: self => self.hook(Audio, () => {
            const vol = Audio.speaker.volume * 100;
            let iconName;

            if (Audio.speaker.isMuted) {
                iconName = 'audio-volume-muted-symbolic';
            } else if (vol > 100) {
                iconName = 'audio-volume-overamplified-symbolic';
            } else if (vol > 66) {
                iconName = 'audio-volume-high-symbolic';
            } else if (vol > 33) {
                iconName = 'audio-volume-medium-symbolic';
            } else {
                iconName = 'audio-volume-low-symbolic';
            }

            icon.icon = iconName;
            icon.toggleClassName('volume-over-100', vol > 100);
        }),
    });

    const showPopup = () => {
        popup.show_all();
    };

    const hidePopup = () => {
        popup.hide();
    };

    button.on('enter-notify-event', showPopup);
    button.on('leave-notify-event', hidePopup);
    popup.on('leave-notify-event', hidePopup);

    App.addWindow(popup);

    const updateVolumeLabel = () => {
        const vol = isFinite(Audio.speaker.volume) ? Math.round(Audio.speaker.volume * 100) : 0;
        volumeLabel.label = `Volume: ${vol.toString().padStart(3, ' ')}%`;
    };

    slider.connect('change-value', updateVolumeLabel);
    Audio.speaker.connect('notify::volume', updateVolumeLabel);
    Audio.speaker.connect('notify::is-muted', updateVolumeLabel);

    updateVolumeLabel(); // Initial update

    return button;
};

export const volumeWidget = VolumeWidget();

// Microphone Widget
export const MicrophoneWidget = () => {
    const slider = Widget.Slider({
        class_name: 'microphone-slider',
        vertical: true,
        inverted: true,
        hexpand: false,
        vexpand: true,
        drawValue: false,
        onChange: ({ value }) => {
            Audio.microphone.volume = isFinite(value) ? value : 0;
        },
        setup: self => self.hook(Audio.microphone, () => {
            self.value = isFinite(Audio.microphone.volume) ? Audio.microphone.volume : 0;
        }),
    });

    const microphoneLabel = Widget.Label({
        class_name: 'microphone-popup-label',
        css: 'min-width: 130px;', // Set a fixed minimum width
    });

    const popupContent = Widget.Box({
        vertical: true,
        css: 'padding: 5px;',
        children: [
            microphoneLabel,
            slider,
        ],
    });

    const popup = Widget.Window({
        name: 'microphone-popup',
        child: popupContent,
        anchor: ['top', 'right'],
        visible: false,
    });

    const icon = Widget.Icon({
        icon: 'microphone-sensitivity-muted-symbolic',
    });

    const button = Widget.Button({
        child: icon,
        onClicked: () => {
            Audio.microphone.isMuted = !Audio.microphone.isMuted;
        },
        onSecondaryClick: () => Utils.execAsync('pavucontrol'),
        onScrollUp: () => {
            Audio.microphone.volume += 0.05;
            Audio.microphone.isMuted = false;
        },
        onScrollDown: () => {
            Audio.microphone.volume -= 0.05;
            Audio.microphone.isMuted = false;
        },
        setup: self => self.hook(Audio, () => {
            const vol = Audio.microphone.volume * 100;
            let iconName;

            if (Audio.microphone.isMuted) {
                iconName = 'microphone-sensitivity-muted-symbolic';
            } else if (vol > 66) {
                iconName = 'microphone-sensitivity-high-symbolic';
            } else if (vol > 33) {
                iconName = 'microphone-sensitivity-medium-symbolic';
            } else {
                iconName = 'microphone-sensitivity-low-symbolic';
            }

            icon.icon = iconName;
        }),
    });

    const showPopup = () => {
        popup.show_all();
    };

    const hidePopup = () => {
        popup.hide();
    };

    button.on('enter-notify-event', showPopup);
    button.on('leave-notify-event', hidePopup);
    popup.on('leave-notify-event', hidePopup);

    App.addWindow(popup);

    const updateMicrophoneLabel = () => {
        const vol = isFinite(Audio.microphone.volume) ? Math.round(Audio.microphone.volume * 100) : 0;
        microphoneLabel.label = `Microphone: ${vol.toString().padStart(3, ' ')}%`;
    };

    slider.connect('change-value', updateMicrophoneLabel);
    Audio.microphone.connect('notify::volume', updateMicrophoneLabel);
    Audio.microphone.connect('notify::is-muted', updateMicrophoneLabel);

    updateMicrophoneLabel(); // Initial update

    return button;
};

export const microphoneWidget = MicrophoneWidget();
