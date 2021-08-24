#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f FFG2-MS_height_10_lcc_739_949_0_004_4_0.grib2

../../bin/download-if-not-exists.sh gust_meps_source.grib

$HIMAN -d 4 -j 1 -f gust_meps.json -t grib --no-cuda gust_meps_source.grib 

grib_compare FFG2-MS_height_10_lcc_739_949_0_004_4_0.grib2 meps_result.grib

if [ $? -eq 0 ];then
  echo gust/meps success on CPU!
else
  echo gust/meps failed on CPU
  exit 1
fi

if [ $(/sbin/lsmod | egrep -c "^nvidia") -gt 0 ]; then

  rm -f FFG2-MS_height_10_lcc_739_949_0_004_4_0.grib2

  $HIMAN -d 4 -j 1 -f gust_meps.json -t grib gust_meps_source.grib

  grib_compare -A 0.2 FFG2-MS_height_10_lcc_739_949_0_004_4_0.grib2 meps_result.grib

  if [ $? -eq 0 ];then
    echo gust/meps success on GPU!
  else
    echo gust/meps failed on GPU
    exit 1
  fi

fi

rm -f FFG2-MS_height_10_lcc_739_949_0_004_4_0.grib2

