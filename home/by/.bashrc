[[ $- != *i* ]] && return

ps1='[\u@\h \w]\$ '

alias ls='ls -lash --color=auto'
alias grep='grep --color=auto'
alias sudo=run0
alias doas=run0
alias vi=nvim
alias vim=nvim
alias free="free -h"
alias fm=ranger
alias bat="echo 'BATTERY LEVEL: $(cat /sys/class/power_supply/BAT1/capacity)'%"
alias scr="echo 'SCREEN BRIGHTNESS: $(($(brightnessctl g) / 2))'%"
alias snd="echo 'SOUND LEVEL: $(echo "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | gawk '{print $2}') * 100" | bc | awk '{print int($1)}')'%"

# Environment variables
export JAVA_HOME="/usr/lib/jvm/default"
