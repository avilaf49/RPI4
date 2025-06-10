#!/bin/bash
cd ~/ea2
export BOX86_LOG=1
export WINEDEBUG=-all
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1
box86 wine eClient.exe
