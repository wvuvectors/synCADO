#! /bin/bash

while getopts ":hi:f:l:c:n:" opt; do
	case $opt in
		h)
			echo "help not available."
			exit 1
			;;
		i)
			# input config file
			cfgFile=$OPTARG
			;;
		f)
			# OG file to assign cross-genome IDs
			ogFile=$OPTARG
			;;
		c)
			# color file mapping OG to color
			ogcolorFile=$OPTARG
			;;
		l)
			# label file mapping OG to label
			oglabelFile=$OPTARG
			;;
		n)
			# name or title of project
			NAME=$OPTARG
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

if [ -z "$cfgFile" ]; then
	echo "FATAL : A tab-delimited config file is required (-c CFG_FILE) but was not provided."
	echo "FATAL : A proper config file contains the path to gff file, data set title, and offset value for each input genome."
	exit 0
fi

if [ -z "$ogFile" ]; then
	echo "FATAL : An OG (.end) file is required (-f OG_FILE) but was not provided."
	exit 0
fi

if [ -z "$NAME" ]; then
	echo "WARN  : No project name provided. I'll use the default: SYNT"
	NAME="SYNT"
fi


# create the data dir
if [ -d "$NAME" ];then
	rm -r "$NAME/"
fi
mkdir "$NAME/"
mkdir "$NAME/circos/"
mkdir "$NAME/circos/data/"
mkdir "$NAME/circos/etc/"

maxlen=0
maxlen_scaled=0
maxchr="x"


while IFS=$'\t' read -r -a tmp
do
	gffFile="${tmp[0]}"

	if [[ $gffFile =~ ^# ]]; then
		continue
	fi
	
	chr=$(gff_parse.pl "chr" < $gffFile)
	len=$(gff_parse.pl "len" < $gffFile)

	if [ "$len" -gt "$maxlen" ]; then
		maxlen=$len
		maxchr="basis-$chr"
	fi
#	echo "$maxlen"
	
done < $cfgFile



cat > "$NAME/circos/etc/plots_rescaled.conf" <<EOL
<plots>

EOL

cat > "$NAME/circos/etc/plots.conf" <<EOL
<plots>

EOL

r2=.99
r1=.96
r0=.93
color="225,225,225"
labelit=1

while IFS=$'\t' read -r -a tmp
do
	gffFile="${tmp[0]}"
	title="${tmp[1]}"
	offset="${tmp[2]}"
	
	if [[ $gffFile =~ ^# ]]; then
		continue
	fi
	
	if [ -z "$offset" ]; then
		offset=0
	fi


	# extract the chr id and total length of the genome from the gff file
	chr=$(gff_parse.pl "chr" < $gffFile)
	len=$(gff_parse.pl "len" < $gffFile)

	if [ -z "$title" ]; then
		title="$chr"
	fi
	
	#echo "len: $len"
	#echo "max: $maxlen"
	scaleup=$( echo "scale=4; $maxlen/$len" | bc)
	#echo "$scaleup"
	
	# extract CDS coordinates, strandedness, and product descriptions from the gff file
	# chr start end product
	table_extract_col.pl 0,2,3,4,6,8 < $gffFile | grep '\tCDS\t' \
	| grep -v 'pseudo=true' \
	| grep ';protein_id=' \
	| perl -pe 's/^(.+?)\tCDS\t(\d+)\t(\d+)\t(.+?)\t.*?product=(.+?);.*?protein_id=(.+?);.*$/$1\t$2\t$3\t$4\t$5\t$6/gi' \
	| perl -pe 's/fig\|//gi' \
	| table_abut.pl 1 2 > "$NAME/$title.feature_table.1.txt"
	
	
	# add OG assignments
	table_add_OG.pl -i 5 $ogFile < "$NAME/$title.feature_table.1.txt" > "$NAME/tmp1.txt"
	
	# add custom colors
	if [ ! -z "$ogcolorFile" ]; then
		table_merge.pl "$NAME/tmp1.txt" 6 "$ogcolorFile" 0 -p "color=white" | table_square.pl 8 > "$NAME/tmp2.txt"
		mv "$NAME/tmp2.txt" "$NAME/tmp1.txt"
	fi
	
	# add custom labels
	if [ ! -z "$oglabelFile" ]; then
		table_merge.pl "$NAME/tmp1.txt" 6 "$oglabelFile" 0  -p "1" | table_square.pl 9 > "$NAME/tmp2.txt"
		mv "$NAME/tmp2.txt" "$NAME/tmp1.txt"
	fi
	
	mv "$NAME/tmp1.txt" "$NAME/$title.feature_table.2.w_OGs.txt"
	
	# apply offset to coordinates
	table_offset.pl 1,2 -c $len -m $offset < "$NAME/$title.feature_table.2.w_OGs.txt" | table_sort.pl 1 -n > "$NAME/$title.feature_table.3.offset.txt"
#	table_offset.pl 1,2 -c $len -m $offset < "$NAME/$title.feature_table.2.w_OGs.txt" | table_sort.pl 1 -n > "$NAME/$title.feature_table.3.offset.tmp"
#	table_abut.pl 1 2 < "$NAME/$title.feature_table.3.offset.tmp" > "$NAME/$title.feature_table.3.offset.txt"
	
	# scale up coordinates
	table_scale.pl 1,2 -s $scaleup -r < "$NAME/$title.feature_table.3.offset.txt" > "$NAME/$title.feature_table.4.scaled.txt"
	
	# replace chr with basis
	# compress 2 or more consecutive unlabeled features
	table_extract_col.pl 0 -i < "$NAME/$title.feature_table.4.scaled.txt" | table_add_col.pl -v "$maxchr" -c 0 | table_compress.pl 8 -t 2 > "$NAME/$title.feature_table.5.compressed.txt"
	
	# also re-scale
	table_extract_col.pl 0 -i < "$NAME/$title.feature_table.4.scaled.txt" | table_add_col.pl -v "$maxchr" -c 0 | table_compress.pl 8 -t 2 -s 50 > "$NAME/$title.feature_table.6.rescaled.tmp"
	

	len_scaled=$(tail -n 1 "$NAME/$title.feature_table.6.rescaled.tmp" | perl -p -e 's/^.+?\t.+?\t(.+?)\t.+$/$1/')
	if [ "$len_scaled" -gt "$maxlen_scaled" ]; then
		maxlen_scaled=$len_scaled
	fi
	
	
	# prepare circos files
	if [ ! -z "$ogcolorFile" ]; then
		table_extract_col.pl 0,1,2,7 < "$NAME/$title.feature_table.5.compressed.txt" > "$NAME/circos/data/$title.wheel_colors.txt"
	fi
	if [ ! -z "$oglabelFile" ]; then
		table_extract_col.pl 0,1,2,8 < "$NAME/$title.feature_table.5.compressed.txt" > "$NAME/circos/data/$title.wheel_labels.txt"
	fi

	cat >> "$NAME/circos/etc/plots.conf" <<EOL
<plot>

show   = yes
type   = tile
file   = data/$title.wheel_colors.txt
layers = 1
layers_overflow=collapse

margin = 0.02u

thickness   = 40p
padding     = 2p
orientation = center

fill							= yes
stroke_thickness = 0.4
stroke_color     = black
color            = white
r1               = ${r2}r
r0               = ${r1}r

<backgrounds>
<background>
color							= $color
</background>
</backgrounds>

</plot>

EOL
	cat >> "$NAME/circos/etc/plots_rescaled.conf" <<EOL
<plot>

show   = yes
type   = text
file   = data/$title.wheel_labels.rescaled.txt

margin = 0.02u

show_links											= no
label_size											= 16p
label_font											= condensed
#label_parallel 					 			= yes
#label_rotate										= no
label_snuggle										= yes
max_snuggle_distance						= 2r
snuggle_sampling								= 2
snuggle_tolerance								= 0.25r
snuggle_refine									= yes

r1               = ${r2}r
r0               = ${r1}r

<backgrounds>
<background>
color							= $color
</background>
</backgrounds>

</plot>

<plot>

show   = yes
type   = tile
file   = data/$title.wheel_colors.rescaled.txt
layers = 1
layers_overflow=collapse

margin = 0.02u

thickness   = 40p
padding     = 2p
orientation = center

fill							= yes
stroke_thickness = 0.4
stroke_color     = black
color            = white
r1               = ${r1}r
r0               = ${r0}r

<backgrounds>
<background>
color							= $color
</background>
</backgrounds>

</plot>

EOL

	r2=$(echo "($r2-0.07)"| bc -l)
	r1=$(echo "($r1-0.07)"| bc -l)
	r0=$(echo "($r0-0.07)"| bc -l)
	
	if [ "$color" = "225,225,225" ]; then
		color="205,205,205"
	else
		color="225,225,225"
	fi
	
done < $cfgFile

cat >> "$NAME/circos/etc/plots_rescaled.conf" <<EOL
</plots>
EOL

cat >> "$NAME/circos/etc/plots.conf" <<EOL
</plots>
EOL


echo "chr	-	$maxchr	$maxchr	0	$maxlen	grey" > "$NAME/circos/karyotype.txt"
echo "chr	-	$maxchr	$maxchr	0	$maxlen_scaled	grey" > "$NAME/circos/karyotype.rescaled.txt"


# fix the rescaling to encompass full ideogram
while IFS=$'\t' read -r -a tmp
do
	gffFile="${tmp[0]}"
	title="${tmp[1]}"
	offset="${tmp[2]}"
	
	if [[ $gffFile =~ ^# ]]; then
		continue
	fi
	
	len_scaled=$(tail -n 1 "$NAME/$title.feature_table.6.rescaled.tmp" | perl -p -e 's/^.+?\t.+?\t(.+?)\t.+$/$1/')
	scaleup=$( echo "scale=4; $maxlen_scaled/$len_scaled" | bc)
	# scale up coordinates
	table_scale.pl 1,2 -s $scaleup -r < "$NAME/$title.feature_table.6.rescaled.tmp" > "$NAME/$title.feature_table.6.rescaled.txt"

	# prepare circos files
	if [ ! -z "$ogcolorFile" ]; then
		table_extract_col.pl 0,1,2,7 < "$NAME/$title.feature_table.6.rescaled.txt" > "$NAME/circos/data/$title.wheel_colors.rescaled.txt"
	fi
	if [ ! -z "$oglabelFile" ]; then
		table_extract_col.pl 0,1,2,8 < "$NAME/$title.feature_table.6.rescaled.txt" > "$NAME/circos/data/$title.wheel_labels.rescaled.txt"
	fi

done < $cfgFile


cat > "$NAME/circos/run_rescaled" <<EOL
#!/bin/bash

echo "Creating image and writing report to run_rescaled.out."

circos -conf etc/circos_rescaled.conf -debug_group summary,timer > run_rescaled.out

EOL


cat >> "$NAME/circos/run" <<EOL
#!/bin/bash

echo "Creating image and writing report to run.out."

circos -conf etc/circos.conf -debug_group summary,timer > run.out

EOL



cat > "$NAME/circos/etc/circos_rescaled.conf" <<EOL

karyotype=karyotype.rescaled.txt

chromosomes_order_by_karyotype = yes
chromosomes_units              = 1000
chromosomes_display_default    = yes

<<include etc/ideogram.conf>>
<<include etc/ticks.conf>>
<<include etc/plots_rescaled.conf>>

<image>
<<include etc/image_rescaled.conf>>
</image>

# includes etc/colors.conf
#          etc/fonts.conf
#          etc/patterns.conf
<<include etc/colors_fonts_patterns.conf>>

# system and debug settings
<<include etc/housekeeping.conf>>

anti_aliasing* = no

EOL



cat > "$NAME/circos/etc/circos.conf" <<EOL

karyotype=karyotype.txt

chromosomes_order_by_karyotype = yes
chromosomes_units              = 1000
chromosomes_display_default    = yes

<<include etc/ideogram.conf>>
<<include etc/ticks.conf>>
<<include etc/plots.conf>>

<image>
<<include etc/image.conf>>
</image>

# includes etc/colors.conf
#          etc/fonts.conf
#          etc/patterns.conf
<<include etc/colors_fonts_patterns.conf>>

# system and debug settings
<<include etc/housekeeping.conf>>

anti_aliasing* = no

EOL



cat > "$NAME/circos/etc/image_rescaled.conf" <<EOL

background = white

dir   = .
file  = $NAME.rescaled.png
png   = yes
svg   = yes
# radius of inscribed circle in image
radius         = 2000p

# by default angle=0 is at 3 o'clock position
angle_offset      = -90

#angle_orientation = counterclockwise

auto_alpha_colors = yes
auto_alpha_steps  = 5

EOL



cat > "$NAME/circos/etc/image.conf" <<EOL

background = white

dir   = .
file  = $NAME.png
png   = yes
svg   = yes
# radius of inscribed circle in image
radius         = 2000p

# by default angle=0 is at 3 o'clock position
angle_offset      = -90

#angle_orientation = counterclockwise

auto_alpha_colors = yes
auto_alpha_steps  = 5

EOL


cat > "$NAME/circos/etc/ideogram.conf" <<EOL

<ideogram>

<spacing>
default = 0.005r
</spacing>

radius    = 0.85r
thickness = 1p
fill      = yes

stroke_thickness = 0
stroke_color     = white
fill_color       = white

show_label       = no
label_font       = default 
label_radius     = 1r + 150p
label_size       = 34
label_parallel   = yes

</ideogram>

EOL



cat > "$NAME/circos/etc/ticks.conf" <<EOL

show_ticks       = yes
show_tick_labels = yes


<ticks>

radius    = 1.0r
color     = black
thickness = 1p

# the tick label is derived by multiplying the tick position
# by 'multiplier' and casting it in 'format':
# # sprintf(format,position*multiplier)

multiplier       = 1e-6

# %d   - integer
# %f   - float
# %.1f - float with one decimal
# %.2f - float with two decimals
# # for other formats, see http://perldoc.perl.org/functions/sprintf.html

format           = %.2f

<tick>
# major tick marks
spacing        = 100u
size           = 6p
show_label     = yes
label_size     = 9p
label_offset   = 2p
label_font     = bold
format         = %.1f
color          = black
</tick>

<tick>
# labeled minor tick marks
spacing        = 20u
size           = 3p
show_label     = yes
label_size     = 6p
label_offset   = 2p
format         = %.2f
color          = dgrey
</tick>

<tick>
# unlabeled minor tick marks
spacing        = 5u
size           = 2p
show_label     = no
color          = lgrey
</tick>

</ticks>

EOL


chmod +x "$NAME/circos/run"
chmod +x "$NAME/circos/run_rescaled"

cd "$NAME/circos/"
./run
./run_rescaled


exit

