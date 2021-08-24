#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f TF*.grib

$HIMAN -d 5 -f frost_point_ecmwf.json -t grib --no-cuda PGR-PA_ground_0_ll_3600_1801_0_001.grib TD-K_ground_0_ll_3600_1801_0_001.grib

grib_compare -A 0.001 TF-C_height_0_rll_661_576_0_001.grib ecmwf_result.grib
if [ $? -eq 0 ];then
  echo frost_point/ecmwf success on CPU!
else
  echo frost_point/ecmwf failed on CPU
  exit 1
fi

rm -f TF*.grib
