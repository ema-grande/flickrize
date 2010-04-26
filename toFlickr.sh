#!/bin/sh
#Prepare photo to upload.

#TODO
#1.firma foto
#2.ridimensiona foto
#3.copia nella cartella toUpload

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
	echo "usage -- $0 <photo sorce> <sign color> <sign pos> <photo orientation>";
	echo "\t<photo sorce>\t\tphoto source file"
	echo "\t<sign color>\t\tSet the color of the sign, default is white. Can be:"
	echo "\t\t\t\t\tW -- White sign"
	echo "\t\t\t\t\tB -- Black sign"
	echo "\t<sign pos>\t\tWhere to put the sign, default is BR. Can be:"
	echo "\t\t\t\t\tBR -- (Bottom Right)"
	echo "\t\t\t\t\tBL -- (Bottom Left)"
	#echo "\t<photo orientation>\t\tPhoto Orientation, can be: O=orizontal V=vertical"
}

#Sign photo
if [ "$ORIG" = "-help" ];then
	usage;
	return $OK
fi

#TODO
#Check if file exist
#if [ ![-f $ORIG] ];then
#	echo "File not found"
#	exit 
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

