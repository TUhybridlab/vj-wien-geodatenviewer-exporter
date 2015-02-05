#!/bin/bash

## Parameters
export __VJ_INTERMEDIATE_GRAPHICS_FORMAT__="tiff"
export __VJ_RESOLUTION_TEXTURE__="2048x2048"
export __VJ_RESOLUTION_HEIGHTMAP__="2049"
export __VJ_GRAVITY_SOUTH_THRESHOLD__="32"

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
		SOURCE_IMAGE_NAME=$i"_op.jpg"


		if [ -f $SOURCE_IMAGE_NAME ]
		then

			if [ -f $SCALED_IMAGE_NAME ]
			then
				echo $i": scaled texture already there, not scaling."
			else
				GRAVITY=""
				if [ `echo $i | cut -d"_" -f 1` -lt $__VJ_GRAVITY_SOUTH_THRESHOLD__ ]
				then
					GRAVITY="South"
				else
					GRAVITY="North"
				fi
				echo $i": scaling down."
				convert -limit thread 2 $SOURCE_IMAGE_NAME -gravity $GRAVITY -resize 12.5% -extent $__VJ_RESOLUTION_TEXTURE__+0+0 $SCALED_IMAGE_NAME
			fi

			PATCHES=$PATCHES" "$SCALED_IMAGE_NAME

		else
			echo "Adding empty patch"
			PATCHES=$PATCHES" "../empty.tiff
		fi

	done
	cd ..

	## Compose
	cd textures
	echo "## Compose texture (i.e. orthofoto)"
	echo $PATCHES

	montage $PATCHES -geometry $__VJ_RESOLUTION_TEXTURE__+0+0 -tile $__VJ_SIZE_Y__x$__VJ_SIZE_X__ ./texture_composed.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__

	# TODO: Somehow unify Texture and heightmap resolution / aspect ratio - trim is not enough
	convert ./texture_composed.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__ -resize $__VJ_RESOLUTION_TEXTURE__ -trim ../out/texture_scaled.tiff
	cd ..
}

function convertTiff2Raw {
	## Convert to RAW format
	cd out
	echo "## Convert to RAW (experimental)"

	# Not sure why, but for some reason needed
	convert multipatch.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__ -flip -trim multipatch_final.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__

	# Convert TIFF to RAW heightmap
	#     Credits: https://alastaira.wordpress.com/2013/11/12/importing-dem-terrain-heightmaps-for-unity-using-gdal/
	gdal_translate -ot UInt16 -of ENVI -scale multipatch_final.$__VJ_INTERMEDIATE_GRAPHICS_FORMAT__ heightmap.raw
	cd ..
}

function getParameters() {
	# Get parameters
	echo -n "Enter Start Major [12 .. 59] and press [ENTER]: "
	read __VJ_START_MAJOR__
	export __VJ_START_MAJOR__

	echo -n "Enter Start Minor [1, 2] and press [ENTER]: "
	read __VJ_START_MINOR__
	export __VJ_START_MINOR__

	echo -n "Enter X-Size and press [ENTER]: "
	read __VJ_SIZE_X__
	export __VJ_SIZE_X__

	echo -n "Enter Y-Size and press [ENTER]: "
	read __VJ_SIZE_Y__
	export __VJ_SIZE_Y__

	if [ $OSTYPE == "cygwin" ]
	then
		echo "Running in cygwin, setting PYTHONPATH"
		export PYTHONPATH=:/qgis/apps/qgis/python
		export PYTHONPATH=$PYTHONPATH:/qgis/apps/Python27/Lib/site-packages
		export QGIS_PREFIX_PATH=/gqis/apps/gqis
	fi
}

## Python: generated with parameters above
COORDINATES=`python convert_coordinates.py`

echo $0

getParameters

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
