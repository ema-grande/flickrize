#!/bin/sh
#Prepare the envoirement for flickrize script
#very basic XD

chmod +x *.sh
mkdir $(cat conf | grep RESPHOTOF | cut -d= -f2)
