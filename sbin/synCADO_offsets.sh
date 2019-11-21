#! /bin/bash


while IFS=$'\t' read -r -a tmp
do
	gffFile="${tmp[0]}"
	gffTitle="${tmp[1]}"

	if [[ $gffFile =~ ^# ]]; then
		echo "#gff_file	title	offset"
		continue
	fi
	
	offset=$(og_getpos.pl 4216 -g "$gffFile" < pgsyn.end)

	echo "$gffFile	$gffTitle	$offset"
	
done < "input_config_all.txt"

