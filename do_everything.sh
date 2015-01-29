#!/bin/bash

# Clean up
#!/bin/bash

rm -rf out

mkdir -p zips
mkdir -p asc
mkdir -p textures
mkdir -p out

COORDINATES=`python convert_coordinates.py`
SIZE=`python get_size.py`
TEXTURE_SCALE_FACTOR="5%"

## Download files
function downloadFiles() {
	cd zips
	echo "## Download"
	for i in $COORDINATES
	do
		# Download ASC file
		downloadPath="https://www.wien.gv.at/ma41datenviewer/downloads/ma41/geodaten/dom_asc/"$i"_dom.zip"
		wget -nc $downloadPath

		# Download orthophoto
		downloadPath="https://www.wien.gv.at/ma41datenviewer/downloads/ma41/geodaten/op_img/"$i"_op.zip"
		wget -nc $downloadPath
	done
	cd ..
}

# Unzip only if needed
function unzipFiles() {
	cd zips
	echo "## Unzip"
	for i in $COORDINATES
	do
		#Textures
		if [ -f "../textures/"$i"_op.jpg" ]
		then
			echo $i": texture already there, not unzipping."
		else
			unzip -o -d ../textures $i"_op.zip"
		fi

		#Oberflaechenmodell
		if [ -f "../asc/"$i"_DOM.asc" ]
		then
			echo $i": \"oberflaechenmodell\" already there, not unzipping."
		else
			unzip -o -d ../asc $i"_dom.zip"
		fi
	done
	cd ..
}

function scaleComposeTextures() {
	## Scale down 
	cd textures
	echo "## Scale down orthophoto"
	PATCHES=""
	for i in $COORDINATES
	do
		if [ -f $i"_scaled.jpg" ]
		then
			echo $i": scaling texture already there, not scaling."
		else
			echo $i": scaling down."
			convert -limit thread 2 $i"_op.jpg" -scale $TEXTURE_SCALE_FACTOR $i"_scaled.jpg"
		fi
		PATCHES=$PATCHES" "$i"_scaled.jpg"
	done
	cd ..

	## Compose
	cd textures
	echo "## Compose texture (i.e. orthofoto)"
	echo $PATCHES
	montage $PATCHES -geometry +0+0 -tile $SIZEx$SIZE ../out/texture_scaled.jpg
	cd ..
}

function convertTiff2Raw {
	## Convert to RAW format
	cd out
	echo "## Convert to RAW (experimental)"
	# Mirror over y = -x axis (not sure why, unitiy seems to do that as well)
	# num 1
	convert multipatch.tiff -rotate 45 -flip -rotate -45 -gravity Center -page +0+0 multipatch_mirrored.tiff
	#nmum 2
	#convert multipatch.tiff -rotate -45 -flip -rotate 45 -gravity Center -page +0+0 multipatch_mirrored.tiff

	convert multipatch_mirrored.tiff -gravity center -crop 2049x2049+0+0 multipatch_final.tiff
	# Credits: https://alastaira.wordpress.com/2013/11/12/importing-dem-terrain-heightmaps-for-unity-using-gdal/
	gdal_translate -ot UInt16 -of ENVI -outsize 2049 2049 -scale multipatch_final.tiff heightmap_1.raw
	cd ..
}

## Main

downloadFiles

unzipFiles

scaleComposeTextures

## Convert and compose meshes
echo "## Converting and composing mesh"
./convert_asc2tiff.py

convertTiff2Raw
