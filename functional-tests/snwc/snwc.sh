#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f RADGLO* RADLW*

$HIMAN -d 5 -f radiation.json -t grib2 source.grib2 --no-cuda

grib_compare RADGLO-WM2_height_0_polster_765_840_0_004.grib2 result-glo.grib2

if [ $? -ne 0 ];then
  echo snwc failed on CPU
  exit 1
fi

grib_compare RADLW-WM2_height_0_polster_765_840_0_004.grib2 result-lw.grib2

if [ $? -eq 0 ];then
  echo snwc success on CPU!
else
  echo snwc failed on CPU
  exit 1
fi

rm -f RADGLO* RADLW*
