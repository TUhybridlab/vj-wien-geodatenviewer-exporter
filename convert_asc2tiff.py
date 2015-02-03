#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

import os

from PyQt4.QtCore import QSize
from PyQt4.QtGui import QImage, QPainter, QColor

from qgis.core import QgsMapLayerRegistry, QgsRasterLayer, QgsRectangle, QgsApplication, QgsMapRenderer

from convert_coordinates import getNext
from get_size import getSize

def getLayer(path, name):
	print "Load ", name
	ret = QgsRasterLayer(path, name)
	if ret.isValid():
		print "    ... is valid"
		QgsMapLayerRegistry.instance().addMapLayer(ret)
	else:
		print "    ERROR: " + path

	return ret

def renderLayers(size, layers, imageFileName):

	imgSize = QSize(size, size)

	# create image
	img = QImage(imgSize, QImage.Format_RGB32)

	# set image's background color
	color = QColor(255,255,255)
	img.fill(color.rgb())


	# create painter
	p = QPainter()
	p.begin(img)
	p.setRenderHint(QPainter.Antialiasing)

	render = QgsMapRenderer()

	# set layer set
	render.setLayerSet(layers.keys())

	# set extent
	rect = QgsRectangle(render.fullExtent())
	render.setExtent(rect)

	# set output size
	render.setOutputSize(img.size(), img.logicalDpiX())

	print "render()"
	# do the rendering
	render.render(p)
	p.end()
	print "    ...Done"

	print "save("+ imageFileName + ")"
	# save image
	img.save(imageFileName)
	print "    ...Done"

def load_layers():
	ascFolder = os.getcwd() + "/asc/"
	x, n = getNext()
	for i in range(getSize()[0] * getSize()[1]):
		fileName = str(x[0]) + "_" + str(x[1]) + "_DOM.asc"
		getLayer(ascFolder + fileName, fileName)
		x, n = getNext(x, n)

if __name__ == "__main__":

	outputImageName="multipatch." + str(os.environ['__VJ_INTERMEDIATE_GRAPHICS_FORMAT__'])

	print "initQgis"
	qgishome = "/usr"
	QgsApplication.setPrefixPath(qgishome, True)
	QgsApplication.initQgis()
	print QgsApplication.showSettings()

	print "    ...Done"

	load_layers()

	style='templatestyle.qml'
	print "Set style:", style
	for layer in QgsMapLayerRegistry.instance().mapLayers().values():
		layer.loadNamedStyle(style)
	print "    ...Done"

	# Render all loaded layers (works with project files to)
	resolution = os.environ["__VJ_RESOLUTION_HEIGHTMAP__"]

	renderLayers(int(resolution), QgsMapLayerRegistry.instance().mapLayers(), "./out/"+outputImageName)

	print "exit"
	QgsApplication.exitQgis()
