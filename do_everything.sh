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

# Compose meshes
./compose_meshes.sh
