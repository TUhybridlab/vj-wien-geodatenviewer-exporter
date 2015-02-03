#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

from get_size import getSize
import os

# Fetch parameters from environment
start_major = int(os.environ['__VJ_START_MAJOR__'])
start_minor = int(os.environ['__VJ_START_MINOR__'])

# Specific do internet data
LINE_SHIFT=10

def getNext((major, minor) = (None, None), n = 0):
	if (major is None):
		return (start_major, start_minor), 0
	# End of Line
	if not (n < getSize()[0] - 1):
		# Next line is low Minors
		if minor > 2:
			if (start_minor < 3):
				return (major + LINE_SHIFT - n / 2,  start_minor), 0
			else:
				return (major + LINE_SHIFT - n / 2,  (start_minor % 3) + 1), 0
		# Next line is high Minors
		else:
			if (start_minor < 3):
				return (major - n/2, start_minor + 2), 0
			else:
				return (major - n/2, start_minor), 0

	# Normal case
	n += 1
	# Odd Minors
	if (minor % 2 == 1):
		return (major, minor + 1), n
	# Even Minors
	if (minor % 2 == 0):
		return (major + 1, minor - 1), n

if __name__ == "__main__":

	size=getSize()

	x, n = getNext()
	for i in range(size[0] * size[1]):
		if (n == 0):
			print
		print str(x[0]) + "_" + str(x[1]),
		x, n = getNext(x, n)
