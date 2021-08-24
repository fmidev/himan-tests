#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f POP-PRCNT*.grib

$HIMAN -d 5 -j 1 -f pop_ec.json --no-cuda source.grib

grib_compare -A 1e-5 POP-PRCNT_height_0_rll_661_576_0_012.grib result.grib 

if [ $? -eq 0 ];then
  echo pop/ecmwf success on CPU!
else
  echo pop/ecmwf failed on CPU
  exit 1
fi
rm -f POP-PRCNT*.grib

