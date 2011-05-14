#!/bin/sh
#Prepare photo to upload.

###############		Subfunction		######################
usage ()
{
	echo "usage: $0 [OPTION]... FILENAME...";
	echo "\tFILENAME\t\tRelative path of the photo file to folder";
	echo "\t\t\t\t\t$PWD"
	echo
	echo "\t--color=COLOR\t\tSet the color of the sign, default is white. COLOR can be:";
	echo "\t\t\t\t\tW -- White sign";
	echo "\t\t\t\t\tB -- Black sign";
	echo "\t--pos=POS\t\tWhere to put the sign, default is BR. POS can be:";
	echo "\t\t\t\t\tTL -- (Top Left)";
	echo "\t\t\t\t\tTR -- (Top Right)";
	echo "\t\t\t\t\tBL -- (Bottom Left)";
	echo "\t\t\t\t\tBR -- (Bottom Right)";
	echo "\t--title=TITLE\t\tSet TITLE of the photo. Will be the file name!";

}

###############		Variables		######################
#Error code
OK=0;				#everuthing is ok!

DEBUG=0				#DebugInfo: = 1 to print debug info

#Resized photo destination folder (this folder must be exist)
TOUPF=$(cat conf | grep RESPHOTOF | cut -d= -f2)

###############		Param Parser		######################
for param in $@; do
	case ${param} in
	"-h" | "-help" | "--help" )
		usage;
		return $OK;;
	"--color="* )		#Catch sign color
		COLOR=${param##*=};;
	"--pos="* )			#Catch sign position
		POS=${param##*=};;
	"--title="* )
		TITLE=${param##*=};;
	* )
		if [ -f "$param" ]
	 	then
	 	 	ORIG="$param"
	 	else
	 		echo "$param is not a file"
	 		usage;
	 		return $OK;
	 	fi;;
	esac
done

if [ "$ORIG" = "" ]; then
	usage;
	return $OK;
fi

echo "Processing photo $ORIG"
./addSignature.sh --color=$COLOR --pos=$POS $ORIG		#Sign photo with addSignature.sh script

#Resize photo
EXT=${ORIG##*.};
SOURCE=${ORIG%*.$EXT}"_sign.$EXT";		#Source signed file
#Output file
DEST=${ORIG%*.$EXT}"_sign_resized."$EXT	#Destination signed file
RDEST=${DEST##*/}						#Photo name
PFOLDER=$(dirname $DEST);				#Photo folder

echo "\tCoping and resizing photo..."
if [ -z $TITLE ]
then
	TITLE=${ORIG##*/}
	TITLE=${TITLE%*.$EXT}"_sign.$EXT"
else
	DEST=$PFOLDER/$TITLE.$EXT;
	RDEST=$TITLE.$EXT;
fi

if [ $DEBUG -eq 1 ]
then
	echo "\t#### DEBUG INFO ####\tOrigin file: $ORIG"
	echo "\t#### DEBUG INFO ####\tTitle: $TITLE"
	echo "\t#### DEBUG INFO ####\tSOURCE: $SOURCE"
	echo "\t#### DEBUG INFO ####\tDEST: $DEST"
	echo "\t#### DEBUG INFO ####\tRDEST: $RDEST"
	echo "\t#### DEBUG INFO ####\tPFOLDER: $PFOLDER"
fi

cp $SOURCE $DEST
mogrify -geometry 1280 $DEST
#End Resize photo

#Move resized photo to toUpload folder
if [ ! -d ${TOUPF} ]
then
	mkdir ${TOUPF}
fi
mv $DEST $TOUPF/$RDEST
echo "\tFile stored to $TOUPF/$RDEST"
#backup photo to signed/$TITLE
mkdir $PFOLDER/signed 2> /dev/null
mv $SOURCE $PFOLDER/signed/$TITLE.$EXT
echo "Processing photo $ORIG Done!"

exit

