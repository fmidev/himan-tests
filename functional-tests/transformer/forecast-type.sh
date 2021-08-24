#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f ./T-K_height_2_polster_*grib*

$HIMAN -d 5 -f forecast-type.json -t grib2 --no-cuda source-forecast-type.grib -s

grib_compare result-forecast-type.grib2 ./T-K_height_2_polster_685_765_0_090_3_2.grib2

if [ $? -eq 0 ];then
  echo forecast-type success!
else
  echo forecast-type failed
  exit 1
fi

rm -f ./T-K_height_2_polster_*grib*

