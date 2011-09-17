#!/bin/bash
# Add signature to the photo.
# Set $WSIGN and $BSIGN to the sign file path

###############		Subfunction		######################
usage ()
{
	echo -e"usage: $0 [OPTION]... FILENAME...";
	echo -e"\tFILENAME\t\tRelative path of the photo file to folder";
	echo -e"\t\t\t\t\t$PWD"
	echo
	echo -e"\t--color=COLOR\t\tSet the color of the signature. COLOR can be:";
	echo -e"\t\t\t\t\tW -- White sign (default)";
	echo -e"\t\t\t\t\tB -- Black sign";
	echo -e"\t--pos=POS\t\tWhere to put the signature. POS can be:";
	echo -e"\t\t\t\t\tTL -- Top Left";
	echo -e"\t\t\t\t\tTR -- Top Right";
	echo -e"\t\t\t\t\tBL -- Bottom Left";
	echo -e"\t\t\t\t\tBR -- Bottom Right (default)";

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
for param in $@; do
	#echo -e"Parametro: $param"
	case ${param} in
	"-h" | "-help" | "--help" )
		usage
		return $OK;;
	"--color="* )		#Catch sign color
		case ${param##*=} in
		"B" )
			SIGN="$BSIGN"
			echo -e"\tSignature color: black!";;
		"W" )
			SIGN="$WSIGN"
			echo -e"\tSignature color: white!";;
		* )
			echo -e"\tSignature color: bottom right! (Default)";;
		esac;;
	"--pos="* )
		case ${param##*=} in
		"TL" )
			SPOS="TL"
			echo -e"\tSignature position: top left!";;
		"TR" )
			SPOS="TR"
			echo -e"\tSignature position: top right!";;
		"BL" )
			SPOS="BL"
			echo -e"\tSignature position: bottom left!";;
		"BR" )
			SPOS="BR"
			echo -e"\tSignature position: bottom right!";;
		* )
			echo -e"\tSignature position: bottom right! (Default)";;
		esac;;
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

if [ -z $ORIG ]; then
	usage;
	return $OK;
fi

###############		Variables		######################
#Output file #TODO set from conf file
EXT=${ORIG##*.};
DEST=${ORIG%*.$EXT}"_sign.$EXT";

###############		Image and sign size		######################
#Calculate image size
SIZE=$(exiv2 $ORIG | grep -i "image size") 2> /dev/null;
SIZE=${SIZE#*:*};
HEIGHT=${SIZE#*x*};
WIDTH=${SIZE%*x*};

#Resize sign file #TODO change this, generalize on photo dimensions
: $((PERCENT = $WIDTH * 100 / 4288 ))	#firma.png must be 1000x200px

#Prepare sign file
if [ ${PERCENT} -ne 100 ]; then
	cp "$SIGN" "$SIGN""_tmp"
	mogrify -resize "$PERCENT""%" "$SIGN""_tmp"
	SIGN="$SIGN""_tmp"
fi

#Calculate sign size for better positioning
SIGNSIZE=$(exiv2 $SIGN | grep -i "image size") 2> /dev/null;
SIGNSIZE=${SIGNSIZE#*:*};
SHEIGHT=${SIGNSIZE#*x*};
SWIDTH=${SIGNSIZE%*x*};

#Calculate sign position #TODO generalize on photo dimension
: $((BORDER = $WIDTH * 20 / 4288 ))
: $((XPOS = $WIDTH - $SWIDTH - $BORDER)); # = Photo xSize - ($SIGN Width + 20)
: $((YPOS = $HEIGHT - $SHEIGHT - $BORDER)); # = Photo ySize - ($SIGN Height + 20)

#ORIZONTAL PHOTO
TL="+$BORDER+$BORDER";		#TOP LEFT
TR="+$XPOS+$BORDER";		#TOP RIGHT
BL="+$BORDER+$YPOS";		#BOTTOM LEFT
BR="+$XPOS+$YPOS";	#BOTTOM RIGHT

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
	echo -e"\t#### DEBUG INFO ####\tOrigin file: $ORIG"
	echo -e"\t#### DEBUG INFO ####\tDestination file: $DEST"
	echo -e"\t#### DEBUG INFO ####\tExtension file: $EXT"
	echo -e"\t#### DEBUG INFO ####\tFile size: $SIZE\t" #$WIDTH x $HEIGHT"
	echo -e"\t#### DEBUG INFO ####\tSign color: $SIGN"
	echo -e"\t#### DEBUG INFO ####\tSign size: $SIGNSIZE\t" #$SWIDTH x $SHEIGHT"
	echo -e"\t#### DEBUG INFO ####\tPercentuale di ridimensionamento:" $PERCENT"%"
	echo -e"\t#### DEBUG INFO ####\tPosizione sign: $SIGNPOS"
	echo -e"\t#### DEBUG INFO ####\tBorder Sign: $BORDER"
fi

###############		Apply		######################
composite -geometry $SIGNPOS $SIGN $ORIG $DEST;
rm *tmp 2> /dev/null

echo -e"\tPhoto signed output is $DEST";

exit 0;
