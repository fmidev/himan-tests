#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f ./T-K_height_2_polster_*grib*

$HIMAN -d 5 -f grib2-number.json -t grib2 --no-cuda source-grib2-number.grib -s

d=$(grib_get -p discipline ./T-K_height_2_polster_685_765_0_090.grib2)

if [ $d -eq 10 ];then
  echo grib2-number success!
else
  echo grib2-number failed
  exit 1
fi

rm -f ./T-K_height_2_polster_*grib*

