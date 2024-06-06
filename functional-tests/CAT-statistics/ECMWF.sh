#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f fc*.grib2

../../bin/download-if-not-exists.sh CAT-statistics_ec_source.grib
 
$HIMAN -d 5 -f CAT_statistics_ec.json -t grib2 --no-cuda CAT-statistics_ec_source.grib

grib_compare fc202406030000+001h00m.grib2 result_ec.grib2

if [ $? -eq 0 ];then
  echo CAT-statistics/ECMWF success on CPU!
else
  echo CAT-statistics/ECMWF failed on CPU
  exit 1
fi

rm -f fc*.grib2
