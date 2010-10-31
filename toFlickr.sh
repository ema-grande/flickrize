#!/bin/sh
#Prepare photo to upload.

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

#Error code
OK=0;			#everuthing is ok!
SIGN_POS_ERR=1;	#return 1 if sign position is no specified!
SIGN_COL_ERR=2;	#return 2 if sign color is no specified!

ORIG="$1"		#Source file
COLOR="$2"		#Signature color
POS="$3"		#Signature position
EXT=${ORIG##*.};
TITLE="$4.$EXT"

DEBUG=0			#DebugInfo: = 1 to print debug info

if [ "$ORIG" = "" -o "$ORIG" = "-h" -o "$ORIG" = "-help" -o "$ORIG" = "--help" ]
then
	usage;
	return $OK;
fi

echo "Processing photo $ORIG"
./addSignature.sh $ORIG $COLOR $POS		#Sign photo with addSignature.sh script

#Resize photo
#Source signed file
SOURCE=${ORIG%*.$EXT}
SOURCE=$(echo "$SOURCE""_sign.$EXT")

#Output file
DEST=${ORIG%*.$EXT}
DEST=$(echo "$DEST""_sign_resized.$EXT")
#Photo name
RDEST=${DEST##*/}
PFOLDER=$(dirname $DEST);

echo "\tCoping and resizing photo..."
if [ -z $4 ]
then
	TITLE=${ORIG##*/}
	TITLE=${TITLE%*.$EXT}
	TITLE="$TITLE""_sign.$EXT"
else
	DEST=$PFOLDER/$TITLE;
	RDEST=$TITLE;
	if [ $DEBUG -eq 1 ]
	then
		echo "\t#### DEBUG INFO ####\tPFOLDER:$PFOLDER\tDEST:$DEST\tRDEST:$RDEST"
	fi
fi

if [ $DEBUG -eq 1 ]
then
	echo "\t#### DEBUG INFO ####\tTITLE: $TITLE"
	echo "\t#### DEBUG INFO ####\tSOURCE: $SOURCE"
	echo "\t#### DEBUG INFO ####\tDEST: $DEST"
	echo "\t#### DEBUG INFO ####\tRDEST: $RDEST"
	echo "\t#### DEBUG INFO ####\tPFOLDER: $PFOLDER"
fi

cp $SOURCE $DEST
mogrify -geometry 1280 $DEST
#End Resize photo

#Move resized photo to toUpload folder
mv $DEST ../toUpload/$RDEST
echo "\tFile stored to ../toUpload/$RDEST"
#backup photo to signed/$TITLE
mkdir $PFOLDER/signed 2> /dev/null
mv $SOURCE $PFOLDER/signed/$TITLE
echo "Processing photo $ORIG Done!"

exit

