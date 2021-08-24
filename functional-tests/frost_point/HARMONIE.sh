#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f TF*.grib2

$HIMAN -d 5 -f frost_point_harmonie.json -t grib --no-cuda P-PA_height_0_rll_720_800_0_015.grib TD-C_height_2_rll_720_800_0_015.grib

grib_compare -A 0.001 TF-C_height_0_rll_720_800_0_000h15min.grib2 harmonie_result.grib
if [ $? -eq 0 ];then
  echo frost_point/harmonie success on CPU!
else
  echo frost_point/harmonie failed on CPU
  exit 1
fi

rm -f TF*.grib2
