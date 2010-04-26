#!/bin/sh
#Rinomina i file foto con l'ora di scatto prima del nome

#Formato file: ora_DSC_numseq.JPG

SEP="_"
DSC="DSC"
EXT=".JPG"

for f in *__*$EXT;do
	FNAMENEXT=${f%*$EXT};											#nome file senza estensione
	TIME=${FNAMENEXT%*__*};										#Ora di scatto della foto
	FNAME=${FNAMENEXT#*__};										#Nome foto (DSC1923)
	NUM=${FNAME#*DSC};												#Num foto

#	echo "time="$TIME "fname="$FNAME "num="$NUM
	#Rinamina la foto in base a sequenza variabili
	mv $f "$TIME$SEP$DSC$SEP$NUM.JPG"
done
