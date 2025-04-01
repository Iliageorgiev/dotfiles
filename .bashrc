#
# ~/.bashrc
#bash-autocomplition#
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
  fi
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias cl='clear'
alias ...='cd ../..'
alias ..='cd ..'
alias ~='cd ~'
alias ls='lsd'
alias ll='ls -la --color=auto'
alias grep='grep --color=auto'
#alias fuck='thefuck'
eval "$(thefuck --alias)"
PS1='[\u@\h \W]\$ '
alias gs='config status'
alias gc='config commit'
alias gp='config push'
alias hyprconf='micro ~/.config/hypr/hyprland.conf'
alias waybarconf='micro ~/.config/waybar/config.jason'
alias waybarstyle='micro ~/.config/waybar/style.css'
alias gad='config add'
alias grm='config checkout -- '
fastfetch
eval "$(starship init bash)"

alias config='/usr/bin/git --git-dir=/home/baiken80/.dotfiles --work-tree=/home/baiken80'


#bind '"\e[B":menu-complete'#
bind 'set show-all-if-ambiguous on'		
# Enable history navigation with arrow keys
    bind '"\e[A":history-search-backward'
    bind '"\e[B":history-search-forward'
bind '"\C-r": reverse-search-history'
## Recoloring #####


LS_COLORS='di=34:ln=35:so=32:pi=3:ex=31:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;4
3:'

di=34
ln=35
so=32
pi=3
ex=31

### Auto Completion###


bind 'set completion-ignore-case on'

# The next line updates PATH for Yandex Cloud CLI.
if [ -f '/home/baiken80/yandex-cloud/path.bash.inc' ]; then source '/home/baiken80/yandex-cloud/path.bash.inc'; fi

# The next line enables shell command completion for yc.
if [ -f '/home/baiken80/yandex-cloud/completion.bash.inc' ]; then source '/home/baiken80/yandex-cloud/completion.bash.inc'; fi

export QT_QPA_PLATFORMTHEME=qt6ct


function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(bat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

eval "$(fzf --bash)"
