#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f POP-PRCNT*.grib2

$HIMAN -d 5 -j 1 -f pop_smartmet.json --no-cuda source.grib

grib_compare -A 1e-5 POP-PRCNT_height_0_polster_255_280_0_044.grib2 result.grib 

if [ $? -eq 0 ];then
  echo pop/smartmet success on CPU!
else
  echo pop/smartmet failed on CPU
  exit 1
fi
rm -f POP-PRCNT*.grib2

