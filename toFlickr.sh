#!/bin/bash
#Prepare photo to upload.

###############		Subfunction		######################
usage ()
{
	echo -e "usage: $0 [OPTION]... FILENAME...";
	echo -e "\tFILENAME\t\tRelative path of the photo file to folder";
	echo -e "\t\t\t\t\t$PWD"
	echo
	echo -e "\t--color=COLOR\t\tSet the color of the sign, default is white. COLOR can be:";
	echo -e "\t\t\t\t\tW -- White sign";
	echo -e "\t\t\t\t\tB -- Black sign";
	echo -e "\t--pos=POS\t\tWhere to put the sign, default is BR. POS can be:";
	echo -e "\t\t\t\t\tTL -- (Top Left)";
	echo -e "\t\t\t\t\tTR -- (Top Right)";
	echo -e "\t\t\t\t\tBL -- (Bottom Left)";
	echo -e "\t\t\t\t\tBR -- (Bottom Right)";
	echo -e "\t--title=TITLE\t\tSet TITLE of the photo. Will be the file name!";

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
		exit $OK;;
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
	 		echo -e "$param is not a file"
	 		usage;
	 		exit $OK;
	 	fi;;
	esac
done

if [ "$ORIG" = "" ]; then
	usage;
	exit $OK;
fi

echo -e "Processing photo $ORIG"
./addSignature.sh --color=$COLOR --pos=$POS $ORIG		#Sign photo with addSignature.sh script

#Resize photo
SOURCE=`echo $ORIG | sed -e 's/\.[a-zA-Z0-9]\{3\}/_sign&/g'`;
#Output file
DEST=`echo $ORIG | sed -e 's/\.[a-zA-Z0-9]\{3\}/_sign_resized&/g'`	#Destination signed file
RDEST=`basename "$DEST"`				#Photo name
PFOLDER=`dirname "$DEST"`;				#Photo folder

echo -e "\tCoping and resizing photo..."
if [ -z $TITLE ]
then
	echo "titolo no"
	TITLE=`basename "$ORIG"`
	TITLE=`echo $TITLE | sed -e 's/\.[a-zA-Z0-9]\{3\}/_sign&/g'`;
else
	echo "titolo si"
	TITLE=$TITLE`echo $ORIG | sed -e 's/^\(.*\)\./\./g'`;
	DEST=$PFOLDER/$TITLE;
	RDEST=$TITLE;
fi

if [ $DEBUG -eq 1 ]
then
	echo -e "\t#### DEBUG INFO ####\tOrigin file: $ORIG"
	echo -e "\t#### DEBUG INFO ####\tTitle: $TITLE"
	echo -e "\t#### DEBUG INFO ####\tOrigin extension: $EXT"
	echo -e "\t#### DEBUG INFO ####\tSOURCE: $SOURCE"
	echo -e "\t#### DEBUG INFO ####\tDEST: $DEST"
	echo -e "\t#### DEBUG INFO ####\tRDEST: $RDEST"
	echo -e "\t#### DEBUG INFO ####\tPFOLDER: $PFOLDER"
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
echo -e "\tFile stored to $TOUPF/$RDEST"
#backup photo to signed/$TITLE
mkdir $PFOLDER/signed 2> /dev/null
mv $SOURCE $PFOLDER/signed/$TITLE
echo -e "Processing photo $ORIG Done!"

exit

