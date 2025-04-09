#!/bin/bash

#
# SESSION LOGOUT MANAGER
# ~/.config/hypr/hyprland/logout.sh
#

case $1 in
  --shutdown)
    notify-send --urgency=critical --expire-time=2000 --app-name="SYSTEM" "SHUTTING DOWN"
    sleep 3
    poweroff
    ;;
  --reboot)
    notify-send --urgency=critical --expire-time=2000 --app-name="SYSTEM" "REBOOTING"
    sleep 3
    reboot
    ;;
  --lock)
    hyprlock
    ;;
  --suspend)
    notify-send --urgency=critical --expire-time=2000 --app-name="SYSTEM" "SUSPENDING"
    sleep 3
    loginctl suspend
    ;;
  *)
    notify-send --urgency=low --app-name="SYSTEM" "Invalid Parameter" "Nothing will happen"
    echo "Invalid parameter"
    ;;
esac
