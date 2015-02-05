# wien-geodatenviewer-exporter
A scriptset allowing download and conversion of data from https://www.wien.gv.at/ma41datenviewer/public/start.aspx

# Requirements

* bash (other shells might work as well)
* imagemagick (convert, montage)
* unzip
* wget
* python2.7
* pyqt4
* qgis, python-qgis >= 2.6
* gdal_translate

# Usage

Just execute do_everything.sh.

# Import to Unity

If you use "meters" as default unit in Unity use the following import settings:

All heightmaps are 16 Bit, Mac ending.

| Nr   | Heightmap resolution | Terrain size        |
|------|----------------------|---------------------|
| 1    | 1367 x 2049          | 10000 x 410 x 15000 |
| 2, 3 | 2049 x 2049          | 5000 x 410 x 5000   |
| 4    | 2049 x 1537          | 10000 x 410 x 7500  |
| 5    | 2049 x 821           | 12500 x 410 x 5000  |
| 6    | 1025 x 2049          | 5000 x 410 x 10000  |
