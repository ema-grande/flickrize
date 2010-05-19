#!/bin/sh
#Add signature to the photo.

#TODO
#1.sign photo				- DONE
#2.check if file exist			- TODO
#3.generalize on file renaming		- TODO
#4.photo orientation (oriz or vert)	- TODO
#5.auto reconize photo size		- DONE
#6.resize sign to check photo size	- TODO

#Input vars
#Source file
ORIG="$1";
SC="$2";
SP="$3";

#Output file
DEST=${ORIG%*.JPG};
DEST=$(echo "$DEST""_sign.JPG");

#Error code
OK=0;		#everuthing is ok
POS_ERR=1;	#return 1 if sign position is no specified

#Sign file
WSIGN="firma2_w.png";	#white signature
BSIGN="firma2_b.png";	#black signature
SIGN=$WSIGN;

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

#TODO add OR statement
if [ "$ORIG" = "" ];then
	usage;
	return $OK;
fi
if [ "$ORIG" = "-help" ];then
	usage;
	return $OK;
fi

#Calculate image size
SIZE=$(exiv2 $ORIG | grep -i "image size") 2> /dev/null;
SIZE=${SIZE#*:*};
HEIGHT=${SIZE#*x*};
WIDTH=${SIZE%*x*};
#echo "Image:" $WIDTH "x" $HEIGHT

#Resize sign file
: $((PERCENT = $WIDTH * 100 / 4288 ))
#echo "Percentuale di ridimensionamento:" $PERCENT"%"

#TODO Adjust this "if"
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

#Prepare sign file
cp "$SIGN" "$SIGN""_tmp"
mogrify -resize "$PERCENT""%" "$SIGN""_tmp"
SIGN="$SIGN""_tmp"
#echo $SIGN

#Calculate sign size for better positioning
SIGNSIZE=$(exiv2 $SIGN | grep -i "image size") 2> /dev/null;
SIGNSIZE=${SIGNSIZE#*:*};
SHEIGHT=${SIGNSIZE#*x*};
SWIDTH=${SIGNSIZE%*x*};
#echo "Sign:" $SWIDTH"x"$SHEIGHT

#Calculate sign position #TODO Change number with $SHEIGHT $SWIDTH vars
: $((XPOS = $WIDTH - $SWIDTH - 20)); #1020 = Photo xSize - ($SIGN Width + 20)
: $((YPOS = $HEIGHT - $SHEIGHT - 20)); #220 = Photo ySize - ($SIGN Height + 20)

#ORIZONTAL PHOTO
#BOTTOM RIGHT
BR="+$XPOS+$YPOS";
#BOTTOM LEFT
BL="+20+$YPOS";
#VERTICAL PHOTO
#BOTTOM RIGHT
VBR="+2620+3260";
#BOTTOM LEFT
VBL="+2620+20";

#echo "Image size:$WIDTH x $HEIGHT", "Sign Pos: BR_$BR BL_$BL"

#Default is BR
SIGNPOS="$BR";

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
rm $SIGN

echo "Photo signed output is $DEST";

exit
