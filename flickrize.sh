#!/bin/sh
#Read README file before run this script!

#TODO set from conf file
photosourcepath="upload.txt"

cat ${photosourcepath} | while read num color pos title;do ./toFlickr.sh --color=$color --pos=$pos --title=$title $num;done
