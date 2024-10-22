# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# USER DEFINED ALIASES
alias doas=sudo
alias vi=nvim
alias vim=nvim
alias free="free -h"
alias ls="ls -lash --color=auto"
alias grep="grep --color=auto"
alias fm="ranger"
alias bat="echo 'BATTERY LEVEL: $(cat /sys/class/power_supply/BAT1/capacity)'%"
alias scr="echo 'SCREEN BRIGHTNESS: $(($(brightnessctl g) / 2))'%"
alias snd="echo 'SOUND LEVEL: $(echo "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | gawk '{print $2}') * 100" | bc | awk '{print int($1)}')'%"
