#!/bin/sh

set -uxe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f RRR*grib2

$HIMAN -d 5 -f ppn.json --no-cuda -s stat -t grib2 ppn_source.tif

miss=$(grib_get -p numberOfMissing RRR-KGM2_height_0_polster_255_280_0_001.grib2)
ret=$?

if [ $miss -eq 43951 ] && [ $ret -eq 0 ];then
  echo geotiff/ppn success!
else
  echo geotiff/ppn failed
  exit 1
fi

rm -f RRR*grib2
