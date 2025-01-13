#!/bin/bash
case $1 in
  --shutdown)
    notify-send -u critical "System is going to shut down!"
    sleep 1
    poweroff
    ;;
  --reboot)
    notify-send -u critical "System is going to reboot!"
    sleep 1
    reboot
    ;;
  --lock)
    swaylock -f -c 000000
    ;;
  --suspend)
    notify-send -u critical "System will be suspended by now!"
    sleep 1
    loginctl suspend
    ;;
  *)
    echo "Invalid parameter"
    ;;
esac

