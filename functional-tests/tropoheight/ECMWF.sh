#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f TROPO*.grib

../../bin/download-if-not-exists.sh tropoheight_source_ec.grib2
 
$HIMAN -d 5 -f tropopause_ec.json -t grib --no-cuda tropoheight_source_ec.grib2

grib_compare TROPO-FL_height_0_rll_661_576_0_001.grib result_ec.grib

if [ $? -eq 0 ];then
  echo tropopause/ecmwf success on CPU!
else
  echo tropopause/ecmwf failed on CPU
  exit 1
fi

rm -f TROPO*.grib
