#!/bin/sh
#Add signature to the photo.

#TODO
#1.sign photo				- DONE
#2.check if file exist			- TODO
#3.generalize on file renaming		- TODO
#4.photo orientation (oriz or vert)	- TODO
#5.auto reconize photo size		- DONE

#Input vars
#Source file
ORIG="$1"

#Output file
DEST=${ORIG%*.JPG}
DEST=$(echo "$DEST""_sign.JPG");

#Error code
OK=0		#everuthing is ok
POS_ERR=1	#return 1 if sign position is no specified

#Sign file
WSIGN="firma2_w.png"	#white signature
BSIGN="firma2_b.png"	#black signature
SIGN=$WSIGN

#Calculate image size
SIZE=$(exiv2 $ORIG | grep -i "image size")
SIZE=${SIZE#*:*}
HEIGHT=${SIZE#*x*}
WIDTH=${SIZE%*x*}

#Calculate sign position
: $((XPOS = $WIDTH - 1020));
: $((YPOS = $HEIGHT - 220));

#ORIZONTAL PHOTO
#BOTTOM RIGHT
BR="+$XPOS+$YPOS"
#BOTTOM LEFT
BL="+20+$YPOS"
#VERTICAL PHOTO
#BOTTOM RIGHT
VBR="+2620+3260"
#BOTTOM LEFT
VBL="+2620+20"

#echo "Image size:$WIDTH x $HEIGHT", "Sign Pos: BR_$BR BL_$BL"

#Default is BR
SIGNPOS="$BR"

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

#if [ [$ORIG = "-help"] || [$ORIG = ""]];then
if [ "$ORIG" = "-help" ];then
	usage;
	return $OK;
fi

#Signature color
if [ "$2" = "" ];then
	echo "Signature color will be white!";
else
	if [ "$2" = "W" ];then
		SIGN="$WSIGN";
		echo "Signature color will white!";
	fi
	if [ "$2" = "B" ];then
		SIGN="$BSIGN";
		echo "Signature color will black!";
	fi
fi

#Signature position
if [ "$3" = "" ];then
	echo "Signature position will be bottom right!";
else
	if [ "$3" = "BR" ];then
		SIGNPOS="$BR";
		echo "Signature position will be bottom right!";
	fi
	if [ "$3" = "BL" ];then
		SIGNPOS="$BL";
		echo "Signature position will be bottom left!";
	fi
fi

#cp $ORIG $DEST
composite -geometry $SIGNPOS $SIGN $ORIG $DEST;

echo "Photo signed output is $DEST";

exit
