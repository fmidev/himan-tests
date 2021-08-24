#!/bin/sh

set -ux

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

$HIMAN -d 5 -f steps.json --no-cuda bbox.grib -s

if [ $? -ne 0 ] || [ ! -f "P-PA_height_0_ll_40_49_0_004_4_0.grib2" ];then
  echo steps failed
  exit 1
fi

rm -f P-PA_height_0_ll_40_49_0_00*grib2
