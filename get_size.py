#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

import os

sizeX = int(os.environ['__VJ_SIZE_X__'])
sizeY = int(os.environ['__VJ_SIZE_Y__'])

def getSize():
	return sizeX, sizeY

if __name__ == "__main__":
	print getSize()
