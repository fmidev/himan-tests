#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f ./T-C_height_0_ll_1126_461_0_004.grib

$HIMAN -d 5 -f time-interp.json --no-cuda source-time-interp.grib -s

grib_compare ./T-C_height_0_ll_1126_461_0_004.grib result-time-interp.grib

if [ $? -eq 0 ];then
  echo time-interp success!
else
  echo time-interp failed
  exit 1
fi

rm -f ./T-C_height_0_ll_1126_461_0_004.grib

