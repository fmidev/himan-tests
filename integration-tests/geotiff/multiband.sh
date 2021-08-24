#!/bin/sh

set -uxe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f T-K*tif

. $PWD/initsh

$HIMAN -d 5 -f multiband.json --no-cuda -s stat multiband_source.grib -t geotiff

. $PWD/check-dbsh

cnt=$(gdalinfo T-K.tif | grep -c Band)

if [ $? -eq 0 ] && [ $cnt -eq 2 ];then
  echo geotiff/multibands success!
else
  echo geotiff/multibands failed
  exit 1
fi

rm -f T-K*tif new
