#!/bin/sh
#Prepare photo to upload.

#Source file
ORIG="$1"
#Signature color
COLOR="$2"
#Signature position
POS="$3"

usage ()
{
	echo "usage -- $0 <photo sorce> <sign color> <sign pos>";
	echo "\t<photo sorce>\t\tphoto source file"
	echo "\t<sign color>\t\tSet the color of the sign, default is white. Can be:"
	echo "\t\t\t\t\tW -- White sign"
	echo "\t\t\t\t\tB -- Black sign"
	echo "\t<sign pos>\t\tWhere to put the sign, default is BR. Can be:"
	echo "\t\t\t\t\tBR -- (Bottom Right)"
	echo "\t\t\t\t\tBL -- (Bottom Left)"
}

#Sign photo
if [ "$ORIG" = "-help" ];then
	usage;
	return $OK
fi

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

#TODO mv photo to the same $DEST folder
#cd $DEST $PWD/toUpload
#Move resized photo to toUpload folder
RDEST=${DEST##*/}
mv $DEST toUpload/$RDEST
echo "File stored to toUpload/$RDEST"
#End move
echo "$DEST Done!"

exit

