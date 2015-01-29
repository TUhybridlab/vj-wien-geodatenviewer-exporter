import os
#os.chdir("c:\\cygwin64\\home\Juri\\geodata")
#execfile('convert_asc.py')

from PyQt4.QtGui import QImage, QPainter, QColor
from PyQt4.QtCore import QSize

from qgis.core import *

def getLayer(path, name):
	ret = QgsRasterLayer(path, name)
	if ret.isValid():
		print "    ... is valid"
		QgsMapLayerRegistry.instance().addMapLayer(ret)
	else:
		print "ERROR: " + path

	return ret

def renderLayers(size, layers, imageFileName):
	print "Rendering  Layer..."
	# create image
	img = QImage(size, QImage.Format_RGB32)


	# set image's background color
	color = QColor(255,255,255)
	img.fill(color.rgb())


	# create painter
	p = QPainter()
	p.begin(img)
	p.setRenderHint(QPainter.Antialiasing)


	print "instanciate render"
	render = QgsMapRenderer()


	# set layer set
	print layers
	print "setLayerSet()"
	render.setLayerSet(layers.keys())

	# set extent
	rect = QgsRectangle(render.fullExtent())
	print "setExtent()"
	render.setExtent(rect)

	# set output size
	print "setOutputSize()"
	render.setOutputSize(img.size(), img.logicalDpiX())

	print "render()"
	# do the rendering
	render.render(p)
	p.end()

	print "save()"
	# save image
	img.save(imageFileName)

	print "Saved"

def load_layers():
	print "Load Layers:"
	ascFolder = os.getcwd() + "/asc/"
	print "I am in ", ascFolder
	files = os.listdir(ascFolder)
	print files
	for fileName in files:
		if fileName.endswith(".asc"):
			print "Load ", fileName
			getLayer(ascFolder + fileName, fileName)
	print "Done loading"

if __name__ == "__main__":

	print "initQgis"
	qgishome = "/usr"
	QgsApplication.setPrefixPath(qgishome, True)
	QgsApplication.initQgis()

	print "Done"

	print "Remove loaded layers"
	layers = QgsMapLayerRegistry.instance().mapLayers()
	for layer in layers.keys():
		QgsMapLayerRegistry.instance().removeMapLayer(layer)
	print "Done"

	load_layers()

	style='templatestyle.qml'
	print "style:", style
	for layer in QgsMapLayerRegistry.instance().mapLayers().values():
		layer.loadNamedStyle(style)

	# Render all loaded layers (works with project files to)
	renderLayers(QSize(2049,2049), QgsMapLayerRegistry.instance().mapLayers(), "./out/multipatch.tiff")
	print "Done rendering"

	print " Remove loaded layers"
	layers = QgsMapLayerRegistry.instance().mapLayers()
	for layer in layers.keys():
		QgsMapLayerRegistry.instance().removeMapLayer(layer)
	print "Done"

	print "exit"
	QgsApplication.exitQgis()
