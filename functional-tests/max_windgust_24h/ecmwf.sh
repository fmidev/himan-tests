#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

../../bin/download-if-not-exists.sh max_windgust_ecmwf_source.grib
rm -f fc202205300000+024h00m.grib 

$HIMAN -d 5 -j 1 -f ecmwf.json -t grib --no-cuda max_windgust_ecmwf_source.grib

grib_compare fc202205300000+024h00m.grib result.grib

if [ $? -eq 0 ];then
  echo gust/ecmwf success on CPU!
else
  echo gust/ecmwf failed on CPU
  exit 1
fi
