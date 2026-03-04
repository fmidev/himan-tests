#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
        export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f fc*.grib2

../../bin/download-if-not-exists.sh wind-shear_meps_source.grib

$HIMAN -d 5 -f wind_shear.json -t grib2 --no-cuda wind-shear_meps_source.grib

grib_compare -A 0.001 fc202603040300+001h00m.grib2 result.grib2
if [ $? -eq 0 ];then
  echo wind-shear/meps success on CPU!
else
  echo wind-shear/meps failed on CPU
  exit 1
fi

rm -f fc*.grib2
