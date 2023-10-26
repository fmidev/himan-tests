#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f FFG2-MS*

../../bin/download-if-not-exists.sh gust_meps_source.grib

$HIMAN -d 4 -j 1 -f gust_meps.json -t grib2 --no-cuda gust_meps_source.grib 

grib_compare FFG2-MS_height_10_lcc_949_1069_0_004_4_0.grib2 meps_result.grib -A 0.1

if [ $? -eq 0 ];then
  echo gust/meps success on CPU!
else
  echo gust/meps failed on CPU
  exit 1
fi

rm -f FFG2-MS*
