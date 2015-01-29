#!/bin/bash

COORDINATES=`python convert_coordinates.py`
SIZE=`python get_size.py`

SCALE_FACTOR="5%"

cd textures

echo "##Scale down"

## TODO: Only if needed
COUNTER=0
for i in $COORDINATES
do
	# Order them using counter
	convert -limit thread 2 $i"_op.jpg" -scale $SCALE_FACTOR $COUNTER"_"$i"_scaled.jpg"
	COUNTER=`expr $COUNTER + 1`
done

echo "## Compose"
montage *_scaled.jpg -geometry +0+0 -tile $SIZEx$SIZE ../out/texture_scaled.jpg

cd ..
