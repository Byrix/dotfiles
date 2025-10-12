#!/bin/bash

MAXBRIGHT=$(brightnessctl m)
CURRBRIGHT=$(brightnessctl g)
BRIGHT=$((100 * $CURRBRIGHT/$MAXBRIGHT))
echo "$BRIGHT"
