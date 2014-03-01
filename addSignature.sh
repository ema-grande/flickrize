#!/bin/bash
# Add signature to the photo.
# Set $WSIGN and $BSIGN to the sign file path

###############		Subfunction		######################
usage ()
{
	echo -e "usage: $0 [OPTION]... FILENAME...";
	echo -e "	FILENAME		Relative path of the photo file to folder";
	echo -e "					$PWD"
	echo
	echo -e "	--color=COLOR		Set the color of the signature. COLOR can be:";
	echo -e "					W -- White sign (default)";
	echo -e "					B -- Black sign";
	echo -e "	--pos=POS		Where to put the signature. POS can be:";
	echo -e "					TL -- Top Left";
	echo -e "					TR -- Top Right";
	echo -e "					BL -- Bottom Left";
	echo -e "					BR -- Bottom Right (default)";

}

###############		Variables		######################
#Error code
OK=0;				#everuthing is ok!

DEBUG=$(cat conf | grep DEBUG | cut -d= -f2)

#Sign file
WSIGN=$(cat conf | grep WHITESIGN | cut -d= -f2)
BSIGN=$(cat conf | grep BLACKSIGN | cut -d= -f2)

SIGN=$WSIGN;			#Default is white!

###############		Param Parser		######################
# TODO: some control on params
#[ $# -ne 3 ] && usage && exit; # TODO: $PARAM_ERROR
for param in $@; do
	#echo -e "Parametro: $param"
	case ${param} in
	"-h" | "-help" | "--help" )
		usage
		exit $OK;;
	"--color="* | "-c="* )		#Catch sign color
		case ${param##*=} in
		"B" | "b" | "BLACK" | "black")
			SIGN="$BSIGN"
			echo -e " Signature color: black!";;
		"W" | "w" | "white" | "WHITE")
			SIGN="$WSIGN"
			echo -e " Signature color: white!";;
		* )
			echo -e " Signature color: white! (Default)";;
		esac;;
	"--pos="* | "-p="* )
		case ${param##*=} in
		"TL" | "tl")
			SPOS="TL"
			echo -e " Signature position: top left!";;
		"TR" | "tr" )
			SPOS="TR"
			echo -e " Signature position: top right!";;
		"BL" | "bl" )
			SPOS="BL"
			echo -e " Signature position: bottom left!";;
		"BR" | "br")
			SPOS="BR"
			echo -e " Signature position: bottom right!";;
		* )
			echo -e " Signature position: bottom right! (Default)";;
		esac;;
	 * )
	 	if [ -f "$param" ] #TODO: Check if there is 3 param
	 	then
	 	 	ORIG="$param"
	 	else
	 		echo -e "$param is not a file"
	 		usage;
	 		exit $OK;
	 	fi;;
	esac
done

if [ -z $ORIG ]; then
	usage;
	exit $OK;
fi

###############		Variables		######################
#Output file 
#TODO: set from conf file
DEST=`echo $ORIG | sed -e 's/\.[a-zA-Z0-9]\{3\}/_sign&/g'`

###############		Image and sign size		######################
#Calculate image size
SIZE=`exiv2 $ORIG 2> /dev/null | grep -i "image size" | cut -d: -f2`;
WIDTH=`echo $SIZE | cut -dx -f1`;
HEIGHT=`echo $SIZE | cut -dx -f2`;

#Resize sign file #TODO: change this, generalize on photo dimensions
: $((PERCENT = $WIDTH * 100 / 4288 ))	#firma.png must be 1000x200px

#Prepare sign file
if [ ${PERCENT} -ne 100 ]; then
	cp "$SIGN" "$SIGN""_tmp"
	mogrify -resize "$PERCENT""%" "$SIGN""_tmp"
	SIGN="$SIGN""_tmp"
fi

#Calculate sign size for better positioning
SIGNSIZE=`exiv2 $SIGN 2> /dev/null | grep -i "image size" | cut -d: -f2`;
SWIDTH=`echo $SIGNSIZE | cut -dx -f1`;
SHEIGHT=`echo $SIGNSIZE | cut -dx -f2`;

#Calculate sign position #TODO: generalize on photo dimension
: $((BORDER = $WIDTH * 20 / 4288 ))
: $((XPOS = $WIDTH - $SWIDTH - $BORDER)); # = Photo xSize - ($SIGN Width + 20)
: $((YPOS = $HEIGHT - $SHEIGHT - $BORDER)); # = Photo ySize - ($SIGN Height + 20)

#ORIZONTAL PHOTO
TL="+$BORDER+$BORDER";		#TOP LEFT
TR="+$XPOS+$BORDER";		#TOP RIGHT
BL="+$BORDER+$YPOS";		#BOTTOM LEFT
BR="+$XPOS+$YPOS";			#BOTTOM RIGHT

#Default is BR
SIGNPOS="$BR";

###############		Parsing Position parameters		######################
case $SPOS in
	"TL" )
		SIGNPOS="$TL";;
	"TR" )
		SIGNPOS="$TR";;
	"BL" )
		SIGNPOS="$BL";;
	"BR" )
		SIGNPOS="$BR";;
esac

if [ $DEBUG -eq 1 ]; then	#Debug info
	echo -e "\t#### DEBUG INFO ####\tOrigin file: $ORIG"
	echo -e "\t#### DEBUG INFO ####\tDestination file: $DEST"
	echo -e "\t#### DEBUG INFO ####\tExtension file: $EXT"
	echo -e "\t#### DEBUG INFO ####\tFile size: $SIZE" #\t$WIDTH x $HEIGHT"
	echo -e "\t#### DEBUG INFO ####\tSign color: $SIGN"
	echo -e "\t#### DEBUG INFO ####\tSign size: $SIGNSIZE \t$SWIDTH x $SHEIGHT"
	echo -e "\t#### DEBUG INFO ####\tPercentuale di ridimensionamento:" $PERCENT"%"
	echo -e "\t#### DEBUG INFO ####\tPosizione sign: $SIGNPOS"
	echo -e "\t#### DEBUG INFO ####\tBorder Sign: $BORDER"
fi

###############		Apply		######################
composite -geometry $SIGNPOS $SIGN $ORIG $DEST;
rm *tmp 2> /dev/null

echo -e " Photo signed output is $DEST";

exit 0;
