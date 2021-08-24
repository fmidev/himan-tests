#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f CBTCU*.grib

../../bin/download-if-not-exists.sh CB-TCU_cloud_source_ec.grib
 
$HIMAN -d 5 -f CB-TCU_cloud_ec.json -t grib --no-cuda CB-TCU_cloud_source_ec.grib

grib_compare -A 0.1 CBTCU-FL_height_0_rll_661_576_0_001.grib result_ec.grib

if [ $? -eq 0 ];then
  echo CB-TCU/ECMWF success on CPU!
else
  echo CB-TCU/ECMWF failed on CPU
  exit 1
fi

rm -f CBTCU*.grib
