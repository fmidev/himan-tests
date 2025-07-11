#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
        export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f PROB-FROST*.grib2

$HIMAN -d 5 -f frost.json -t grib2 --no-cuda source.grib

grib_compare -A 0.001 PROB-FROST-1_height_0_polster_765_840_0_015.grib2 PF1-result.grib
if [ $? -eq 0 ];then
  echo frost/PROB-FROST-1 success on CPU!
else
  echo frost/PROB-FROST-1 failed on CPU
  exit 1
fi

grib_compare -A 0.001 PROB-FROST-2_height_0_polster_765_840_0_015.grib2 PF2-result.grib
if [ $? -eq 0 ];then
  echo frost/PROB-FROST-2 success on CPU!
else
  echo frost/PROB-FROST-2 failed on CPU
  exit 1
fi

rm -f PROB-FROST*.grib2
