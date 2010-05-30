#!/bin/sh
#Prepare photo to upload.

#Source file
ORIG="$1"
#Signature color
COLOR="$2"
#Signature position
POS="$3"
#Photo Title
TITLE="$4"

usage ()
{
	echo "usage -- $0 <photo sorce> <sign color> <sign pos> <photo title>";
	echo "\t<photo sorce>\t\tphoto source file"
	echo "\t<sign color>\t\tSet the color of the sign, default is white. Can be:"
	echo "\t\t\t\t\tW -- White sign"
	echo "\t\t\t\t\tB -- Black sign"
	echo "\t<sign pos>\t\tWhere to put the sign, default is BR. Can be:"
	echo "\t\t\t\t\tBR -- (Bottom Right)"
	echo "\t\t\t\t\tBL -- (Bottom Left)"
	echo "\t<photo title>\t\tPhoto title"
}

#Sign photo
if [ "$ORIG" = "" ];then
	usage;
	return $OK;
fi
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
#Take photo name
RDEST=${DEST##*/}

echo "\tCoping and resizing photo..."
if [ "$TITLE" != "" ];then
	PFOLDER=${DEST%*/*.JPG};
	DEST=$PFOLDER/$TITLE;
	RDEST=$TITLE;
#	echo "\tPFOLDER:$PFOLDER\tDEST:$DEST\tRDEST:$RDEST"
fi
cp $SOURCE $DEST
mogrify -geometry 1280 $DEST
#End Resize photo

#Move resized photo to toUpload folder
mv $DEST toUpload/$RDEST
echo "\tFile stored to toUpload/$RDEST"
#backup photo to signed/$TITLE
mkdir $PFOLDER/signed 2> /dev/null
mv $SOURCE $PFOLDER/signed/$TITLE
echo "Processing photo $ORIG Done!"

exit

