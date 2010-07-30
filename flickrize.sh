#!/bin/sh
#Read README file before run this script!

cat upload.txt | while read num color pos title;do ./toFlickr.sh $num $color $pos $title;done
