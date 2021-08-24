#!/usr/bin/env python2

import gribapi
import sys

if len(sys.argv) != 5:
    print "usage: %s infile offset bytes outfile" % sys.argv[0]
    print "data is appended to outfile"
    sys.exit(1)

infile = sys.argv[1]
offset = int(sys.argv[2])
length = int(sys.argv[3])
outfile= sys.argv[4]

buff = None

print("Reading from %s offset %d length %d" % (infile, offset, length))
with open(infile, "rb") as fp:
    fp.seek(offset, 0)
    buff = fp.read(length)
    fp.close()

gh = gribapi.grib_new_from_message(buff)

with open(outfile, "a") as fp:
    gribapi.grib_write(gh, fp)

