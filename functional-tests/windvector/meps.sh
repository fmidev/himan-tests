#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f DD-D*.grib2 FF-MS*.grib2

$HIMAN -d 5 -f windvector_meps.json meps_source.grib2 -s meps_nocuda --no-cuda 

grib_compare -A 0.01 meps_result_ff.grib2 ./FF-MS_height_10_lcc_739_949_0_006_3_9.grib2

if [ $? -eq 0 ];then
  echo windvector/meps wind speed success on CPU
else
  echo windvector/meps wind speed failed on CPU
  exit 1
fi

grib_compare -A 1 meps_result_dd.grib2 ./DD-D_height_10_lcc_739_949_0_006_3_9.grib2

if [ $? -eq 0 ];then
  echo windvector/meps wind direction success!
else
  echo windvector/meps wind direction failed
  exit 1
fi

if [ ../../bin/check-for-gpu.sh ]; then

  rm -f DD-D*.grib FF-MS*.grib

  $HIMAN -d 5 -f windvector_meps.json -s meps meps_source.grib2

  grib_compare -A 0.01 meps_result_ff_gpu.grib2 ./FF-MS_height_10_lcc_739_949_0_006_3_9.grib2

  if [ $? -eq 0 ];then
    echo windvector/meps wind speed success GPU
  else
    echo windvector/meps wind speed failed GPU
    exit 1
  fi

  grib_compare -A 1 meps_result_dd.grib2 ./DD-D_height_10_lcc_739_949_0_006_3_9.grib2

  if [ $? -eq 0 ];then
    echo windvector/meps wind direction success GPU
  else
    echo windvector/meps wind direction failed GPU
    exit 1
  fi
fi

rm -f DD-D*.grib2 FF-MS*.grib2

