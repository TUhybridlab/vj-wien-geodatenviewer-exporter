#!/bin/bash

## Parameters
export __VJ_INTERMEDIATE_GRAPHICS_FORMAT__="tiff"

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
		SCALED_IMAGE_NAME=$i"_scaled."$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__
		if [ -f $SCALED_IMAGE_NAME ]
		then
			echo $i": scaling texture already there, not scaling."
		else
			echo $i": scaling down."
			convert -limit thread 2 $i"_op.jpg" -resize 2048x2048 $SCALED_IMAGE_NAME
		fi
		PATCHES=$PATCHES" "$SCALED_IMAGE_NAME
	done
	cd ..

	## Compose
	cd textures
	echo "## Compose texture (i.e. orthofoto)"
	echo $PATCHES
	montage $PATCHES -geometry +0+0 -tile $__VJ_SIZE__x$__VJ_SIZE__ ./texture_composed.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__
	convert ./texture_composed.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__ -resize 2048x2048 ../out/texture_scaled.tiff
	cd ..
}

function convertTiff2Raw {
	## Convert to RAW format
	cd out
	echo "## Convert to RAW (experimental)"

	# Not sure why, but for some reason needed
	convert multipatch.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__ -flip multipatch_final.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__

	# Convert TIFF to RAW heightmap
	#     Credits: https://alastaira.wordpress.com/2013/11/12/importing-dem-terrain-heightmaps-for-unity-using-gdal/
	gdal_translate -ot UInt16 -of ENVI -outsize 2049 2049 -scale multipatch_final.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__ heightmap.raw
	cd ..
}

# Get parameters
echo -n "Enter Start Major [12 .. 59] and press [ENTER]: "
read __VJ_START_MAJOR__
export __VJ_START_MAJOR__

echo -n "Enter Start Minor [1, 2] and press [ENTER]: "
read __VJ_START_MINOR__
export __VJ_START_MINOR__

echo -n "Enter Size (length of a side of a square, where upper left section is ("$__VJ_START_MAJOR__", "$__VJ_START_MINOR__")) [ int ] and press [ENTER]: "
read __VJ_SIZE__
export __VJ_SIZE__

## Python: generated with parameters above
COORDINATES=`python convert_coordinates.py`

## Main
if [[ $0 != "bash" && $0 != "-bash" ]]
then
	# Clean up
	rm -rf out

	# Create directories
	mkdir -p zips
	mkdir -p asc
	mkdir -p textures
	mkdir -p out

	downloadFiles

	unzipFiles

	scaleComposeTextures

	## Convert and compose meshes
	echo "## Converting and composing mesh"
	./convert_asc2tiff.py

	convertTiff2Raw
fi
