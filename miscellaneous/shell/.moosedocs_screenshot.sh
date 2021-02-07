#!/bin/bash

convert -border 8 -bordercolor 'rgb(0,88,151)' $1 $2

convert $2 \( +clone -background '#7A7777' -shadow 88x5+0+5 \) +swap \
	-background none -layers merge +repage $2
