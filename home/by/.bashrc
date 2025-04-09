#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1="[\u@\h: \w]\$ "

function printInfo() {
   printf "%s\n" "$(date '+%A, %Y-%m-%d %H:%M:%S')"
   printf "%s\n" "BATTERY: $(cat /sys/class/power_supply/BAT1/capacity)%"
   printf "%s\n" "UPTIME: $(uptime -p)"
   printf "%s\n\n" "------------------------------"
}

# Aliases for common commands
alias clear="clear && printInfo"
alias grep="rg -p" # https://github.com/BurntSushi/ripgrep
alias histgrep="history | rg '$1'"
alias find="fd" # https://github.com/sharkdp/fd
alias cat="bat" # https://github.com/sharkdp/bat
alias du="dust" # https://github.com/bootandy/dust
alias ls="eza -laxghUMmo --git --icons=auto --sort=Name --time-style='+%Y-%m-%d %H:%M'" # https://github.com/eza-community/eza
alias ps="procs -t" # https://github.com/dalance/procs
alias tree="tree --dirsfirst -F"
alias free="free -h"

# Get the weather report on the command line.
# curl, jq and an API key from 'Openweathermap' are required.
function weather_report() {
   local response=$(curl --silent "https://api.openweathermap.org/data/3.0/onecall?lat=<LATITUDE>&lon=<LONGTITUDE>&appid=<API_KEY>")
   local status=$(echo $response | jq -r ".cod")
   case $status in
      200)
         printf "Location: %s %s\n" "$(echo $response | jq '.name') $(echo $response | jq '.sys.country')"  
         printf "Forecast: %s\n" "$(echo $response | jq '.weather[].description')" 
         printf "Temperature: %.1f°F\n" "$(echo $response | jq '.main.temp')" 
         printf "Temp Min: %.1f°F\n" "$(echo $response | jq '.main.temp_min')" 
         printf "Temp Max: %.1f°F\n" "$(echo $response | jq '.main.temp_max')" 
         ;;
      401)
         echo "401 error"
         ;;
      *)
         echo "error"
         ;;
   esac
}

printInfo
