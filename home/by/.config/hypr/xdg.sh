#!/bin/bash
sleep 1
killall xdg-desktop-portal-hyprland
killall xdg-desktop-portal-gnome
killall xdg-desktop-portal-kde
killall xdg-desktop-portal-gtk
killall xdg-desktop-portal-wlr
killall xdg-desktop-portal-lxqt
killall xdg-desktop-portal-xapp
killall xdg-desktop-portal-dde
killall xdg-desktop-portal
sleep 1
/usr/lib64/xdg-desktop-portal-hyprland &
sleep 1
/usr/lib64/xdg-desktop-portal-gtk &
sleep 1
/usr/lib64/xdg-desktop-portal &
sleep 1
