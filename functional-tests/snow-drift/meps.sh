#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f SNOW*.grib*

$HIMAN -s no-cuda -d 5 -f meps.json -t grib2 source_meps.grib --no-cuda

grib_compare ./SNOWDRIFT-N_height_0_lcc_889_949_0_001_4_0.grib2 result_meps.grib2

if [ $? -eq 0 ];then
  echo snow_drift/meps success on CPU!
else
  echo snow_drift/meps failed on CPU
  exit 1
fi

if [ ../../bin/check-for-gpu.sh ]; then

  rm -f SNOW*.grib2

  $HIMAN -s cuda -d 5 -f meps.json -t grib2 source_meps.grib

  grib_compare ./SNOWDRIFT-N_height_0_lcc_889_949_0_001_4_0.grib2 result_meps.grib2

  if [ $? -eq 0 ];then
    echo snow_drift/meps success on GPU!
  else
    echo snow_drift/meps failed on GPU
  fi
else
  echo "no cuda device found for cuda tests"
fi

rm -f SNOW*.grib* SN*grib*

