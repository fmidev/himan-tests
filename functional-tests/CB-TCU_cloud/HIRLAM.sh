#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f CBTCU*.grib

$HIMAN -d 5 -f CB-TCU_cloud_hirlam.json -t grib --no-cuda source_hirlam.grib 

grib_compare -A 0.1 CBTCU-FL_height_0_rll_1030_816_0_001.grib result_hirlam.grib

if [ $? -eq 0 ];then
  echo CB-TCU/hirlam success on CPU!
else
  echo CB-TCU/hirlam failed on CPU
  exit 1
fi

rm -f CBTCU*.grib
