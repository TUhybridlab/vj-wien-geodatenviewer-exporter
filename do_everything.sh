#!/bin/bash

## Parameters
export INTERMEDIATE_GRAPHICS_FORMAT="tiff"
# Python generated parameters.
#  See the files for the respective values
COORDINATES=`python convert_coordinates.py`
SIZE=`python get_size.py`


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
		SCALED_IMAGE_NAME=$i"_scaled."$INTERMEDIATE_GRAPHICS_FORMAT
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
	montage $PATCHES -geometry +0+0 -tile $SIZEx$SIZE ./texture_composed.$INTERMEDIATE_GRAPHICS_FORMAT
	convert ./texture_composed.$INTERMEDIATE_GRAPHICS_FORMAT -resize 2048x2048 ../out/texture_scaled.tiff
	cd ..
}

function convertTiff2Raw {
	## Convert to RAW format
	cd out
	echo "## Convert to RAW (experimental)"

	# Not sure why, but for some reason needed
	convert multipatch.$INTERMEDIATE_GRAPHICS_FORMAT -flip multipatch_final.$INTERMEDIATE_GRAPHICS_FORMAT

	# Convert TIFF to RAW heightmap
	#     Credits: https://alastaira.wordpress.com/2013/11/12/importing-dem-terrain-heightmaps-for-unity-using-gdal/
	gdal_translate -ot UInt16 -of ENVI -outsize 2049 2049 -scale multipatch_final.$INTERMEDIATE_GRAPHICS_FORMAT heightmap.raw
	cd ..
}

## Main
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
