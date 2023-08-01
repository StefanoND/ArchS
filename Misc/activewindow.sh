#! /bin/env bash

# Detect current active Class name and Window name, usefull for creating rules for KWin or Bismuth

istrue=y

while [[ ${istrue,,} = y ]]; do
    classname=`xdotool getactivewindow getwindowclassname`
    windowname=`xdotool getactivewindow getwindowname`
    echo
    echo "Detecting active Window"
    echo
    echo "--------------------------"
    echo "|         Active         |"
    echo "--------------------------"
    echo
    printf "Class: $classname"
    echo
    echo
    printf "Window: $windowname"
    echo
    echo
    echo "--------------------------"
    echo
    sleep 1s
done

exit 0
