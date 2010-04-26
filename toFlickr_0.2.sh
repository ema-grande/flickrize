#!/bin/sh
#Prepare photo to upload.

#TODO
#1.firma foto						- DONE
#2.ridimensiona foto				- DONE
#3.copia nella cartella toUpload	- DONE
#4.check if file exist				- TODO
#5.generalize on file renaming		- TODO
#6.photo orientation				- TODO

#Source file
ORIG="$1"
#Signature color
COLOR="$2"
#Signature position
POS="$3"
#TODO
#Photo Orientation
ORI="$4"

usage ()
{
	./addSignature.sh -help
}

#Sign photo
if [ "$ORIG" = "-help" ];then
	usage;
	return $OK
fi

#TODO
#Check if file exist
#if [ -f $ORIG ];then
#	echo "File seen to found";
#	exit;
#else
#	echo "File not found";
#	exit;
#fi

echo "Processing photo $ORIG"

./addSignature.sh $ORIG $COLOR $POS
#End Sign photo

#Resize photo
#Source file
SOURCE=${ORIG%*.JPG}
SOURCE=$(echo "$SOURCE""_sign.JPG")
#Output file
DEST=${ORIG%*.JPG}
DEST=$(echo "$DEST""_sign_resized.JPG")

echo "Coping and resizing photo..."
cp $SOURCE $DEST
mogrify -geometry 1280 $DEST
#End Resize photo

#Move resized photo to toUpload folder
#if [ [ -f "toUpload" ] ];then
#	mkdir toUplad
#fi
RDEST=${DEST##*/}
mv $DEST toUpload/$RDEST
echo "File stored to toUpload/$RDEST"
#End move
echo "Done!"

exit

