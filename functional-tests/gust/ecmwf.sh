#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f FFG2-MS_height_10_rll_661_576_0_001.grib

../../bin/download-if-not-exists.sh gust_ecmwf_source.grib

$HIMAN -d 5 -j 1 -f gust_ecmwf.json -t grib --no-cuda gust_ecmwf_source.grib

grib_compare FFG2-MS_height_10_rll_661_576_0_001.grib result.grib

if [ $? -eq 0 ];then
  echo gust/ecmwf success on CPU!
else
  echo gust/ecmwf failed on CPU
  exit 1
fi

rm -f FFG2-MS_height_10_rll_661_576_0_001.grib
