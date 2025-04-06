x = 1
pi = 4
for i in range(50000000):
	x+=2
	pi = pi - (4/x)
	x+=2
	pi = pi + (4/x)
	print(pi)
