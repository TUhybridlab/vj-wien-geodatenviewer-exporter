# wien-geodatenviewer-exporter
A scriptset allowing download and conversion of data from https://www.wien.gv.at/ma41datenviewer/public/start.aspx, which can then be used in Unity3D as a Terrain Object.

# Requirements

* Linux (Windows unsupported yet)
* bash (other shells might work as well)
* imagemagick (convert, montage)
* unzip
* wget
* python2.7
* pyqt4
* qgis, python-qgis >= 2.6 - For Ubuntu see [here](http://qgis.org/en/site/forusers/alldownloads.html#on-plain-ubuntu) and then [here](http://qgis.org/en/site/forusers/alldownloads.html#ubuntu)
* gdal_translate
* exiv2

# Usage

Just execute `do_everything.sh` from within Bash shell.

# Import to Unity

If you use "meters" as default unit in Unity use the following import settings:

* The resolution of the heightmaps is the name of the empty file in the corresponding `out_`-folder.
* All heightmaps are 16 Bit, Mac encoding.
* The terrain sizes are:

| Nr   | X x Y x Z           |
|------|---------------------|
| 1    | 10000 x 410 x 15000 |
| 2, 3 | 5000 x 410 x 5000   |
| 4    | 10000 x 410 x 7500  |
| 5    | 12500 x 410 x 5000  |
| 6    | 5000 x 410 x 10000  |

# Region Map

Implemented: **Red** regions

![Region map](https://github.com/j-be/wien-geodatenviewer-exporter/blob/master/region_map.png)

## Legend

* green: all full width and full height tiles
* red: current implementation status
* yellow: estimate for next implementation
