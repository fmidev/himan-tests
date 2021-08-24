#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f RH*.grib

$HIMAN -d 5 -f relative_humidity_ice_harmonie.json -t grib --no-cuda P-PA_height_0_rll_720_800_0_015.grib T-K_height_2_rll_720_800_0_015.grib TD-C_height_2_rll_720_800_0_015.grib

grib_compare -A 0.001 RHICE-PRCNT_height_0_rll_720_800_0_000h15min.grib2 harmonie_result.grib
if [ $? -eq 0 ];then
  echo relative_humidity_ice/harmonie success on CPU!
else
  echo relative_humidity_ice/harmonie failed on CPU
  exit 1
fi

rm -f RH*.grib2
