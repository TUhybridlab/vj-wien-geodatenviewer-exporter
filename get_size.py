#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

import os

size = start_minor = int(os.environ['__VJ_SIZE__'])

def getSize():
	return size

if __name__ == "__main__":
	print getSize()
