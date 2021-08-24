#!/bin/sh

set -x

#exit 0;

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f hybrid_height_ec.json.grib

$HIMAN -d 5 -f hybrid_height_ec_2.json -t grib source_ec_2.grib

grib_compare ./HL-M_hybrid_137_rll_661_576_0_004.grib2 result_ec_2.grib

if [ $? -eq 0 ];then
  echo hybrid_height/ec_2 success!
else
  echo hybrid_height/ec_2 failed
  exit 1
fi

