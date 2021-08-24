#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f T-MEAN-K*grib*

$HIMAN -d 5 -f time-aggregation-test.json time-aggregation-test-source.grib -s stat --no-cuda -t grib

grib_compare ./T-MEAN-K_height_2_rll_201_221_0_015.grib time-aggregation-test-result.grib

if [ $? -ne 0 ];then
  echo luatool/time-aggregation-test failed on CPU
  exit 1
fi

rm -f T-MEAN-K*grib*

$HIMAN -d 5 -f time-aggregation-test.json time-aggregation-test-source.grib -s stat --no-cuda -t grib2

grib_compare ./T-MEAN-K_height_2_rll_201_221_0_015.grib2 time-aggregation-test-result.grib2


if [ $? -ne 0 ];then
  echo luatool/time-aggregation-test failed on CPU
  exit 1
fi

echo luatool/time-aggregation-test success on CPU!

rm -f T-MEAN-K*grib*
