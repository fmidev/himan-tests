#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
  export HIMAN="../../himan-bin/himan"
fi

rm -f PROB*grib2

../../bin/download-if-not-exists.sh lvp_meps_source.grib2

$HIMAN -s no-cuda -d 4 -f meps.json lvp_meps_source.grib2 --no-cuda

grib_compare PROB-LVP-1_height_0_lcc_949_1069_0_048_5.grib2 meps_result.grib2

if [ $? -eq 0 ];then
  echo lvp/meps success on CPU!
else
  echo lvp/meps failed on CPU
  exit 1
fi

rm -f PROB*grib2

