#!/bin/bash
sleep 1.5 &
bspc rule -a kitty -o state=floating rectangle=240x205+1120+38 sticky=on  & 
paplay /home/vanhg/Downloads/Audio/MissMinutesHi.wav &
kitty --hold --title "My Window" sh -c 'cd /home/vanhg/.config/mminute && kitty @ set-font-size 1 && kitty @ set-colors foreground=#EC7729 && sleep 1.5 && ./animation2'
# /home/vanhg/.config/mminute/launch2.sh
# ./animation