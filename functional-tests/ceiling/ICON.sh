#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f CEIL-2-M_height_0_ll_1377_657_0_001.grib2

../../bin/download-if-not-exists.sh ceiling_icon_source.grib

$HIMAN -d 4 -f ceiling2_icon.json -t grib2 --no-cuda ceiling_icon_source.grib 
grib_compare -A 0.01 CEIL-2-M_height_0_ll_1377_657_0_001.grib2 icon_result.grib

if [ $? -eq 0 ];then
  echo ceiling/icon success on CPU!
else
  echo ceiling/icon failed on CPU
  exit 1
fi

rm -f CEIL-2-M_height_0_ll_1377_657_0_001.grib2
