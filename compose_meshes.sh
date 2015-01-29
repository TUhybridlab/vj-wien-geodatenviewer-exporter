#!/bin/bash

COORDINATES=`python convert_coordinates.py`

#python -m trace --trace convert_asc.py
python convert_asc.py

# EXPERIMENTAL: Convert to RAW format
cd out
# Credits: https://alastaira.wordpress.com/2013/11/12/importing-dem-terrain-heightmaps-for-unity-using-gdal/
gdal_translate -ot UInt16 -of ENVI -outsize 2049 2049 -scale multipatch.tiff heightmap.raw
cd ..
