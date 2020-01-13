#!/usr/bin/env python
# encoding: utf-8
"""
readres.py

Created by ckunte on 2011-07-22.
Copyright (c) 2011. All rights reserved.
"""

import array
import getopt
import math
import struct
import sys

help_message = '''
Come back to this later: The help message goes here.
'''


class Usage(Exception):
	def __init__(self, msg):
		self.msg = msg

reclength = 324

def readres():
	# Record length is 324 in a .RES DYNFLOAT file.
	maxnumsignals = reclength / 4
	# Little endian format for intel processors ('ieee-le' in Matlab).
	# Check system's endianness with the following:
	# >>> import sys
	# >>> sys.byteorder
	# 'little'
	byteorder = 'little'
	fid = open(flnm, 'r', byteorder)
	while fid > 0:
		# First record:
		ns = struct.unpack('i', fid.read(1))
		ci1 = struct.unpack('f', fid.read(1))
		# Second record:
		numlines = struct.unpack('i', fid.read(2))
		numref = struct.unpack('i', fid.read(2))
		numsignals = 37 + numlines + 3 + numref
		rdata = zeros((ns, numsignals)) + nan
		# From the 3rd record, read the rest
		for nn in range(1, ns):
			fid.seek(2 + nn, 0)
			rdata[nn,] = struct.unpack('f', fid.read(numsignals))
	fid.close()
	# Time series
	time = (0:ci1:(ns - 1) * ci1)
	dfld.signals = dynfloatsignals(numlines, numref)
	dfld.data = rdata
	dfld.time = time
	dfld.flnm = flnm
	# C.O.G offset
	indx = find(strncmpi('X_mot', {dfld.signals.dlfName},5))
	indy = find(strncmpi('Y_mot', {dfld.signals.dlfName},5))
	offset = math.sqrt(dfld.data[:,indx].^2 + dfld.data[:indy].^2)
	rdata[:,end] = offset
	dfld.data[:,end] = offset
	dfld.signals(end).dlfname = 'Offset_Ref1'
	dfld.signals(end).dlflabel = 'Vessel offset relative to Reference Pt'
	dfld.signals(end).units = 'm'
	pass






def main(argv=None):
	if argv is None:
		argv = sys.argv
	try:
		try:
			opts, args = getopt.getopt(argv[1:], "ho:v", ["help", "output="])
		except getopt.error, msg:
			raise Usage(msg)
	
		# option processing
		for option, value in opts:
			if option == "-v":
				verbose = True
			if option in ("-h", "--help"):
				raise Usage(help_message)
			if option in ("-o", "--output"):
				output = value
	
	except Usage, err:
		print >> sys.stderr, sys.argv[0].split("/")[-1] + ": " + str(err.msg)
		print >> sys.stderr, "\t for help use --help"
		return 2


if __name__ == "__main__":
	sys.exit(main())
