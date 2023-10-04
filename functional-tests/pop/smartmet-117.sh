#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f POP-PRCNT*.grib2

$HIMAN -d 5 -j 1 -f smartmet-117.json --no-cuda source-117.grib

grib_compare -A 1e-5 POP-0TO1_height_0_polster_255_280_0_044.grib2 result-117.grib

if [ $? -eq 0 ];then
  echo pop/smartmet-117 success on CPU!
else
  echo pop/smartmet-117 failed on CPU
  exit 1
fi
rm -f POP-PRCNT*.grib2

