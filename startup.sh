#!/bin/sh
# (c) Pete Birley

#this sets the vnc password
/usr/local/etc/start-vnc-expect-script.sh

#fixes a warning with starting nautilus on firstboot - which we will always be doing.
mkdir -p ~/.config/nautilus

#this starts the vnc server
USER=root vncserver :1 -geometry 1366x768 -depth 24

#this starts noVNC
/noVNC/utils/launch.sh --vnc 127.0.0.1:5901 --listen 80


add-apt-repository ppa:malizor/gtk-next-broadway -y
apt-get update
apt-get upgrade -y
apt-get install -y broadwayd

broadwayd &




# Drop into a bash prompt (at the working directory)
bash