#!/bin/sh
# Add signature to the photo.
# Set $WSIGN and $BSIGN to the sign file path

###############		Subfunction		######################
usage ()
{
	echo "usage: $0 [OPTION]... FILENAME...";
	echo "\tFILENAME\t\tRelative path of the photo file to folder";
	echo "\t\t\t\t\t$PWD"
	echo
	echo "\t--color=COLOR\t\tSet the color of the signature. COLOR can be:";
	echo "\t\t\t\t\tW -- White sign (default)";
	echo "\t\t\t\t\tB -- Black sign";
	echo "\t--pos=POS\t\tWhere to put the signature. POS can be:";
	echo "\t\t\t\t\tTL -- Top Left";
	echo "\t\t\t\t\tTR -- Top Right";
	echo "\t\t\t\t\tBL -- Bottom Left";
	echo "\t\t\t\t\tBR -- Bottom Right (default)";

}

###############		Variables		######################
#Error code
OK=0;				#everuthing is ok!

DEBUG=0				#DebugInfo: = 1 to print debug info

#Sign file
WSIGN="firma2_w.png";	#White signature
BSIGN="firma2_b.png";	#Black signature
SIGN=$WSIGN;			#Default is white!

###############		Param Parser		######################
for param in $@; do
	#echo "Parametro: $param"
	case ${param} in
	"-h" | "-help" | "--help" )
		usage
		return $OK;;
	"--color="* )		#Catch sign color
		case ${param##*=} in
		"B" )
			SIGN="$BSIGN"
			echo "\tSignature color: black!";;
		"W" )
			SIGN="$WSIGN"
			echo "\tSignature color: white!";;
		* )
			echo "\tSignature color: bottom right! (Default)";;
		esac;;
	"--pos="* )
		case ${param##*=} in
		"TL" )
			SPOS="TL"
			echo "\tSignature position: top left!";;
		"TR" )
			SPOS="TR"
			echo "\tSignature position: top right!";;
		"BL" )
			SPOS="BL"
			echo "\tSignature position: bottom left!";;
		"BR" )
			SPOS="BR"
			echo "\tSignature position: bottom right!";;
		* )
			echo "\tSignature position: bottom right! (Default)";;
		esac;;
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

if [ -z $ORIG ]; then
	usage;
	return $OK;
fi

###############		Variables		######################
#Output file
EXT=${ORIG##*.};
DEST=${ORIG%*.$EXT}"_sign.$EXT";

###############		Image and sign size		######################
#Calculate image size
SIZE=$(exiv2 $ORIG | grep -i "image size") 2> /dev/null;
SIZE=${SIZE#*:*};
HEIGHT=${SIZE#*x*};
WIDTH=${SIZE%*x*};

#Resize sign file
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

#Calculate sign position 
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
	echo "#### DEBUG INFO ####\tOrigin file: $ORIG"
	echo "#### DEBUG INFO ####\tDestination file: $DEST"
	echo "#### DEBUG INFO ####\tExtension file: $EXT"
	echo "#### DEBUG INFO ####\tFile size: $SIZE\t" #$WIDTH x $HEIGHT"
	echo "#### DEBUG INFO ####\tSign color: $SIGN"
	echo "#### DEBUG INFO ####\tSign size: $SIGNSIZE\t" #$SWIDTH x $SHEIGHT"
	echo "#### DEBUG INFO ####\tPercentuale di ridimensionamento:" $PERCENT"%"
	echo "#### DEBUG INFO ####\tPosizione sign: $SIGNPOS"
	echo "#### DEBUG INFO ####\tBorder Sign: $BORDER"
fi

###############		Apply		######################
composite -geometry $SIGNPOS $SIGN $ORIG $DEST;
#rm $SIGN

echo "\tPhoto signed output is $DEST";

exit
