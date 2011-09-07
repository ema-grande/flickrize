#!/bin/bash
#Read README file before run this script!

photosourcepath=$(cat conf | grep SOURCE | cut -d= -f2)

cat ${photosourcepath} | while read num color pos title;do ./toFlickr.sh --color=$color --pos=$pos --title=$title $num;done
