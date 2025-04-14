#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
  export HIMAN="../../himan-bin/himan"
fi

rm -f FEELS*grib2

$HIMAN -d 4 -f meps.json meps_source.grib2 -t grib2 --no-cuda

grib_compare FEELSLIKE-K_height_0_lcc_949_1069_0_003_4_0.grib2 meps_result.grib2

if [ $? -eq 0 ];then
  echo feelslike/meps success on CPU!
else
  echo feelslike/meps failed on CPU
  exit 1
fi
rm -f FEELSLIKE*grib2

