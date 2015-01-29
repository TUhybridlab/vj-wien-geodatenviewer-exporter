from get_size import getSize

# Specific do internet data
LINE_SHIFT=10

def getNext((major, minor), (n, m)):
	# End of Line
	if not (n < getSize() - 1):
		# Next line is low Minors
		if not (m < 1):
			return (major + LINE_SHIFT - (getSize() - 1) / 2, start_minor), (0, 0)
		# Next line is high Minors
		else:
			return (major - n/2, 3), (0, m + 1)

	# Normal case
	n += 1
	# Odd Minors
	if (minor % 2 == 1):
		return (major, minor + 1), (n, m)
	# Even Minors
	if (minor % 2 == 0):
		return (major + 1, minor - 1), (n, m)

if __name__ == "__main__":

	size=getSize()
	start_major=35
	start_minor=1


	x = (start_major, start_minor)
	n = 0
	m = 0
	for i in range(size * size):
		print str(x[0]) + "_" + str(x[1])
		x, (n, m) = getNext(x, (n, m))
