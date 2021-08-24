#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
        export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f PROB-FROST*.grib

$HIMAN -d 5 -f frost.json -t grib --no-cuda source.grib

grib_compare -A 0.001 ./PROB-FROST-1_height_2_polster_255_280_0_016.grib PF1-result.grib
if [ $? -eq 0 ];then
  echo frost/PROB-FROST-1 success on CPU!
else
  echo frost/PROB-FROST-1 failed on CPU
  exit 1
fi

grib_compare -A 0.001 ./PROB-FROST-2_height_2_polster_255_280_0_016.grib PF2-result.grib
if [ $? -eq 0 ];then
  echo frost/PROB-FROST-2 success on CPU!
else
  echo frost/PROB-FROST-2 failed on CPU
  exit 1
fi

rm -f PROB-FROST*.grib
