#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f POT-PRCNT*.grib

../../bin/download-if-not-exists.sh pot_source_ecmwf.grib

$HIMAN -d 5 -j 4 -f pot_ec.json --no-cuda pot_source_ecmwf.grib

grib_compare POT-PRCNT_height_0_ll_3600_1801_0_003.grib result.grib 

if [ $? -eq 0 ];then
  echo pot/ecmwf success on CPU!
else
  echo pot/ecmwf failed on CPU
  exit 1
fi

rm -f POT-PRCNT*.grib
