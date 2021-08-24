#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f CEIL*.grib

../../bin/download-if-not-exists.sh ceiling_ecmwf_source.grib

$HIMAN -d 4 -f ceiling_ecmwf.json -t grib --no-cuda ceiling_ecmwf_source.grib
grib_compare -A 0.01 ./CEIL-M_ground_0_rll_661_576_0_001.grib ecmwf_result.grib
if [ $? -eq 0 ];then
  echo ceiling/ecmwf success on CPU!
else
  echo ceiling/ecmwf failed on CPU
  exit 1
fi

rm -f CEIL*.grib
