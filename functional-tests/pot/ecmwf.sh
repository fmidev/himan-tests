#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f POT-PRCNT*.grib2

../../bin/download-if-not-exists.sh pot_source_ecmwf.grib.bz2

$HIMAN -d 5 -j 4 -f pot_ec.json --no-cuda pot_source_ecmwf.grib.bz2

grib_compare POT-PRCNT_height_0_ll_3600_1801_0_003.grib2 result.grib 

if [ $? -eq 0 ];then
  echo pot/ecmwf success on CPU!
else
  echo pot/ecmwf failed on CPU
  exit 1
fi

rm -f POT-PRCNT*.grib2
