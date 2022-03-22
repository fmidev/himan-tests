#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f *INDEX*.grib2

$HIMAN -d 5 -f meps.json meps_source.grib2 -s meps_nocuda --no-cuda 

grib_compare -A 0.01 meps_result_sfindex.grib2 SFINDEX-0TO1_height_0_polster_765_840_0_012_4_0.grib2

if [ $? -eq 0 ];then
  echo soaring_flight_index/meps success on CPU
else
  echo soaring_flight_index/meps wind speed failed on CPU
  exit 1
fi

grib_compare -A 1 meps_result_tbindex.grib2 TBINDEX-0TO1_height_0_polster_765_840_0_012_4_0.grib2

if [ $? -eq 0 ];then
  echo thermal_bird_index/meps wind direction success!
else
  echo thermal_bird_index/meps wind direction failed
  exit 1
fi

rm -f *INDEX*.grib2
