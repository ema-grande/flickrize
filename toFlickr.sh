#!/bin/bash
#Prepare photo to upload.

###############		Subfunction		######################
usage ()
{
	echo -e"usage: $0 [OPTION]... FILENAME...";
	echo -e"\tFILENAME\t\tRelative path of the photo file to folder";
	echo -e"\t\t\t\t\t$PWD"
	echo
	echo -e"\t--color=COLOR\t\tSet the color of the sign, default is white. COLOR can be:";
	echo -e"\t\t\t\t\tW -- White sign";
	echo -e"\t\t\t\t\tB -- Black sign";
	echo -e"\t--pos=POS\t\tWhere to put the sign, default is BR. POS can be:";
	echo -e"\t\t\t\t\tTL -- (Top Left)";
	echo -e"\t\t\t\t\tTR -- (Top Right)";
	echo -e"\t\t\t\t\tBL -- (Bottom Left)";
	echo -e"\t\t\t\t\tBR -- (Bottom Right)";
	echo -e"\t--title=TITLE\t\tSet TITLE of the photo. Will be the file name!";

}

###############		Variables		######################
#Error code
OK=0;				#everuthing is ok!

DEBUG=$(cat conf | grep DEBUG | cut -d= -f2)

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
	 		echo -e"$param is not a file"
	 		usage;
	 		return $OK;
	 	fi;;
	esac
done

if [ "$ORIG" = "" ]; then
	usage;
	return $OK;
fi

echo -e"Processing photo $ORIG"
./addSignature.sh --color=$COLOR --pos=$POS $ORIG		#Sign photo with addSignature.sh script

#Resize photo
EXT=${ORIG##*.};
SOURCE=${ORIG%*.$EXT}"_sign.$EXT";		#Source signed file
#Output file
DEST=${ORIG%*.$EXT}"_sign_resized."$EXT	#Destination signed file
RDEST=${DEST##*/}						#Photo name
PFOLDER=$(dirname $DEST);				#Photo folder

echo -e"\tCoping and resizing photo..."
if [ -z $TITLE ]
then
	TITLE=${ORIG##*/}
	TITLE=${TITLE%*.$EXT}"_sign"
else
	DEST=$PFOLDER/$TITLE.$EXT;
	RDEST=$TITLE.$EXT;
fi

if [ $DEBUG -eq 1 ]
then
	echo -e"\t#### DEBUG INFO ####\tOrigin file: $ORIG"
	echo -e"\t#### DEBUG INFO ####\tTitle: $TITLE"
	echo -e"\t#### DEBUG INFO ####\tSOURCE: $SOURCE"
	echo -e"\t#### DEBUG INFO ####\tDEST: $DEST"
	echo -e"\t#### DEBUG INFO ####\tRDEST: $RDEST"
	echo -e"\t#### DEBUG INFO ####\tPFOLDER: $PFOLDER"
fi

RDWIDTH=$(cat conf | grep RWIDTH | cut -d= -f2) #resize width
cp $SOURCE $DEST
mogrify -geometry $RDWIDTH $DEST
#End Resize photo

#Move resized photo to toUpload folder
if [ ! -d ${TOUPF} ]
then
	mkdir ${TOUPF}
fi
mv $DEST $TOUPF/$RDEST
echo -e"\tFile stored to $TOUPF/$RDEST"
#backup photo to signed/$TITLE
mkdir $PFOLDER/signed 2> /dev/null
mv $SOURCE $PFOLDER/signed/$TITLE.$EXT
echo -e"Processing photo $ORIG Done!"

exit

