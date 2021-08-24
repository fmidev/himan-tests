#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f RH*.grib

$HIMAN -d 5 -f relative_humidity_ice_hirlam.json -t grib --no-cuda TD-C_height_2_rll_1030_816_0_001.grib T-K_height_2_rll_1030_816_0_001.grib P-PA_height_0_rll_1030_816_0_001.grib

grib_compare -A 0.001 RHICE-PRCNT_height_0_rll_1030_816_0_001.grib hirlam_result.grib
if [ $? -eq 0 ];then
  echo relative_humidity_ice/hirlam success on CPU!
else
  echo relative_humidity_ice/hirlam failed on CPU
  exit 1
fi

rm -f RH*.grib
