#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f LLF*.grib2

../../bin/download-if-not-exists.sh llf-source-ecmwf.grib
 
$HIMAN -d 4 -f ecmwf.json -t grib2 llf-source-ecmwf.grib

grib_compare -A 0.1 LLF-TOP-FL_height_0_rll_661_576_0_009.grib2 result_ecmwf.grib

if [ $? -eq 0 ];then
  echo LLF/ECMWF success on CPU!
else
  echo LLF/ECMWF failed on CPU
  exit 1
fi

rm -f LLF*.grib2
