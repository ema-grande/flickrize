#!/bin/sh
#Add signature to the photo.

#TODO
#1.sign photo								- DONE
#2.check if file exist						- TODO
#3.generalize on file renaming				- TODO
#4.photo orientation (oriz or vert)			- TODO
#5.auto reconize photo size					- DONE
#6.resize sign to check photo size			- DONE
#7.Control if more then 1 photo is passed	- TODO
#8.Parsing parameters						- TODO

usage ()
{
	echo "usage -- $0 <photo sorce> <sign color> <sign pos>";
	echo "\t<photo sorce>\t\tphoto source file";
	echo "\t<sign color>\t\tSet the color of the sign, default is white. Can be:";
	echo "\t\t\t\t\tW -- White sign";
	echo "\t\t\t\t\tB -- Black sign";
	echo "\t<sign pos>\t\tWhere to put the sign, default is BR. Can be:";
	echo "\t\t\t\t\tBR -- (Bottom Right)";
	echo "\t\t\t\t\tBL -- (Bottom Left)";
}

#Error code
OK=0;		#everuthing is ok!
SIGN_POS_ERR=1;	#return 1 if sign position is no specified!
SIGN_COL_ERR=2;	#return 2 if sign color is no specified!

DEBUG=0		#DebugInfo: = 1 to print debug info

#Input vars
ORIG="$1";	#Source file
SC="$2";	#Sign color
SP="$3";	#Sign position

#Output file
EXT=${ORIG##*.};
DEST=${ORIG%*.$EXT}"_sign.$EXT");

#Sign file
WSIGN="firma2_w.png";	#White signature
BSIGN="firma2_b.png";	#Black signature
SIGN=$WSIGN;			#Default is white!

if [ "$ORIG" = "" -o "$ORIG" = "-h" -o "$ORIG" = "-help" -o "$ORIG" = "--help" ];then
	usage;
	return $OK;
fi

#Calculate image size
SIZE=$(exiv2 $ORIG | grep -i "image size") 2> /dev/null;
SIZE=${SIZE#*:*};
HEIGHT=${SIZE#*x*};
WIDTH=${SIZE%*x*};

#Resize sign file
: $((PERCENT = $WIDTH * 100 / 4288 ))

if [ $DEBUG -eq 1 ]; then	#Debug info: image size and resize
	echo "#### DEBUG INFO ####\tImage:" $WIDTH "x" $HEIGHT
	echo "#### DEBUG INFO ####\tPercentuale di ridimensionamento:" $PERCENT"%"
fi

case "$2" in
	"B" )
	SIGN="$BSIGN"
	echo "\tSignature color: black!";;
	"W" )
	SIGN="$WSIGN"
	echo "\tSignature color: white!";;
	* )
	echo "\tDefault signature color: white!";;
esac

#Prepare sign file
cp "$SIGN" "$SIGN""_tmp"
mogrify -resize "$PERCENT""%" "$SIGN""_tmp"
SIGN="$SIGN""_tmp"

#Calculate sign size for better positioning
SIGNSIZE=$(exiv2 $SIGN | grep -i "image size") 2> /dev/null;
SIGNSIZE=${SIGNSIZE#*:*};
SHEIGHT=${SIGNSIZE#*x*};
SWIDTH=${SIGNSIZE%*x*};

if [ $DEBUG -eq 1 ]; then	#Debug info: sign file resize and sign size
	echo "#### DEBUG INFO ####\t$SIGN"
	echo "#### DEBUG INFO ####\tSign:" $SWIDTH"x"$SHEIGHT
fi

#Calculate sign position 
: $((XPOS = $WIDTH - $SWIDTH - 20)); # = Photo xSize - ($SIGN Width + 20)
: $((YPOS = $HEIGHT - $SHEIGHT - 20)); # = Photo ySize - ($SIGN Height + 20)

#ORIZONTAL PHOTO
BR="+$XPOS+$YPOS";	#BOTTOM RIGHT
BL="+20+$YPOS";		#BOTTOM LEFT
#VERTICAL PHOTO
VBR="+2620+3260";	#BOTTOM RIGHT
VBL="+2620+20";		#BOTTOM LEFT

if [ $DEBUG -eq 1 ]; then	#Debug info: Image size, Sign pos and color
	echo "#### DEBUG INFO ####\tImage size:$WIDTH x $HEIGHT", "Sign Pos: BR_$BR BL_$BL"
fi

#Default is BR
SIGNPOS="$BR";

#Signature position
case "$3" in
	"BR" )
	SIGNPOS="$BR"
	echo "\tSignature position: bottom right!";;
	"BL" )
	SIGNPOS="$BL"
	echo "\tSignature position: bottom left!";;
	* )
	echo "\tDefault signature position: bottom right!";;
esac

#cp $ORIG $DEST
composite -geometry $SIGNPOS $SIGN $ORIG $DEST;
rm $SIGN

echo "\tPhoto signed output is $DEST";

exit
