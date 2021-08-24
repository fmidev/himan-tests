#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f TF*.grib

$HIMAN -d 5 -f frost_point_hirlam.json -t grib --no-cuda P-PA_height_0_rll_1030_816_0_001.grib TD-C_height_2_rll_1030_816_0_001.grib

grib_compare -A 0.001 TF-C_height_0_rll_1030_816_0_001.grib hirlam_result.grib
if [ $? -eq 0 ];then
  echo frost_point/hirlam success on CPU!
else
  echo frost_point/hirlam failed on CPU
  exit 1
fi

rm -f TF*.grib
