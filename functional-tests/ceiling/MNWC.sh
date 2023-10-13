#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f CEIL-2-M_height_0_lcc_949_1069_0_001.grib2

../../bin/download-if-not-exists.sh ceiling_mnwc_source.grib

$HIMAN -d 4 -f ceiling2_mnwc.json -t grib2 --no-cuda ceiling_mnwc_source.grib 
grib_compare -A 0.01 CEIL-2-M_height_0_lcc_949_1069_0_001.grib2 mnwc_result.grib

if [ $? -eq 0 ];then
  echo ceiling/mnwc success on CPU!
else
  echo ceiling/mnwc failed on CPU
  exit 1
fi

rm -f CEIL-2-M_height_0_lcc_949_1069_0_001.grib2
