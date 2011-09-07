#!/bin/bash
#Prepare the envoirement for flickrize script
#very basic XD

chmod +x *.sh

SOURCE=$(cat conf | grep DEBUG | cut -d= -f2)
if [ ! -a $SOURCE ]
then
	echo "<photo file path> <sign color> <sign pos> <title>" > $SOURCE
fi

#TODO some more things :)
