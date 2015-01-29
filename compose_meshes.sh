#!/bin/bash

COORDINATES=`python convert_coordinates.py`

#python -m trace --trace convert_asc.py
python convert_asc.py
