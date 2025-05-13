#!/bin/sh

if type "xrandr"; then
	monitors=($(xrandr --query | grep " connected" | cut -d" " -f1))

	if [ ${#monitors[@]} -gt 1 ]; then
		MONITOR=${monitors[1]}
	else
		MONITOR="eDP1"
	fi

	MONITOR=$MONITOR polybar --reload left & 
	MONITOR=$MONITOR polybar --reload right & 
	MONITOR=$MONITOR polybar --reload middle
else
	polybar --reload left & polybar --reload right & polybar --reload middle
fi
