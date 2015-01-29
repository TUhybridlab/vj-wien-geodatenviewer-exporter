#!/bin/bash

# Clean up
#!/bin/bash

rm -rf out

mkdir -p zips
mkdir -p asc
mkdir -p textures
mkdir -p out

COORDINATES=`python convert_coordinates.py`

## Download files
cd zips
for i in $COORDINATES
do
	# Download ASC file
	downloadPath="https://www.wien.gv.at/ma41datenviewer/downloads/ma41/geodaten/dom_asc/"$i"_dom.zip"
	wget -nc $downloadPath

	# Download orthophoto
	downloadPath="https://www.wien.gv.at/ma41datenviewer/downloads/ma41/geodaten/op_img/"$i"_op.zip"
	wget -nc $downloadPath
done

# Unzip
## TOOD: Only if needed
for i in $COORDINATES
do
	unzip -o -d ../textures $i"_op.zip"
	unzip -o -d ../asc $i"_dom.zip"
done

# Back
cd ..

# Compose texures
./compose_scaled_textures.sh

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

## Convert and compose meshes
echo "## Converting and composing mesh"
python convert_asc.py

convertTiff2Raw
