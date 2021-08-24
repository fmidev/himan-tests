#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f BL*.grib
../../bin/download-if-not-exists.sh bl_turbulence_ec_source.grib

$HIMAN -d 5 -f bl_turbulence_ec.json -t grib --no-cuda bl_turbulence_ec_source.grib

grib_compare -A 0.001 BLTURB-N_height_0_rll_661_576_0_001.grib ec_result.grib
if [ $? -eq 0 ];then
  echo bl_turbulence/ec success on CPU!
else
  echo bl_turbulence/ec failed on CPU
  exit 1
fi

rm -f BL*.grib
