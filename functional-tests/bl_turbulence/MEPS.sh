#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f BL*.grib2
../../bin/download-if-not-exists.sh bl_turbulence_meps_source.grib

$HIMAN -d 5 -f bl_turbulence_meps.json -t grib --no-cuda bl_turbulence_meps_source.grib

grib_compare -A 0.001 BLTURB-N_height_0_lcc_949_1069_0_001_4_0.grib2 meps_result.grib
if [ $? -eq 0 ];then
  echo bl_turbulence/meps success on CPU!
else
  echo bl_turbulence/meps failed on CPU
  exit 1
fi

rm -f BL*.grib2
