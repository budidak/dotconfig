#!/bin/bash

#
# XDG DESKTOP PORTAL MANAGER
# ~/.config/hypr/hyprland/xdph.sh
#

sleep 1
killall -e xdg-desktop-portal-hyprland
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-hyprland &
sleep 1
/usr/lib/xdg-desktop-portal-gtk &
sleep 2
/usr/lib/xdg-desktop-portal &
