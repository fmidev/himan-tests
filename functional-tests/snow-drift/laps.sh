#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f SN*.grib*

$HIMAN -s no-cuda -d 5 -f laps-finland.json -t grib2 source_laps.grib --no-cuda

grib_compare ./SNOWDRIFT-N_height_0_polster_270_400_0_000.grib2 result_laps.grib2

if [ $? -eq 0 ];then
  echo snow_drift/laps success on CPU!
else
  echo snow_drift/laps failed on CPU
  exit 1
fi

if [ $(/sbin/lsmod | egrep -c "^nvidia") -gt 0 ]; then

  rm -f SNOW*.grib2

  $HIMAN -s cuda -d 5 -f laps-finland.json -t grib2 source_laps.grib

  grib_compare ./SNOWDRIFT-N_height_0_polster_270_400_0_000.grib2 result_laps.grib2

  if [ $? -eq 0 ];then
    echo snow_drift/laps success on GPU!
  else
    echo snow_drift/laps failed on GPU
  fi
else
  echo "no cuda device found for cuda tests"
fi

rm -f SN*.grib*

