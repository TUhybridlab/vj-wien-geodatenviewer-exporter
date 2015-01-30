from get_size import getSize

start_major=24
start_minor=1

# Specific do internet data
LINE_SHIFT=10

def getNext((major, minor) = (None, None), (n, m) = (0, 0)):
	if (major is None):
		return (start_major, start_minor), (0, 0)
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

	x, (n, m) = getNext()
	for i in range(size * size):
		print str(x[0]) + "_" + str(x[1])
		x, (n, m) = getNext(x, (n, m))
