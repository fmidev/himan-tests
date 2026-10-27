#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f fc202610210600+003h00m.grib2 

$HIMAN -d 5 -j 1 -f meps.json -t grib --no-cuda source.grib

grib_compare fc202610210600+003h00m.grib2 result.grib2

if [ $? -eq 0 ];then
  echo inversion/meps success on CPU!
else
  echo inversion/meps failed on CPU
  exit 1
fi
