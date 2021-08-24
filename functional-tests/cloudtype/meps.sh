#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
  export HIMAN="../../himan-bin/himan"
fi

rm -f CL*grib2

$HIMAN -s no-cuda -d 4 -f meps.json meps_source.grib2 --no-cuda

grib_compare CLDTYPE-N_height_0_lcc_949_1069_0_003_4_0.grib2 meps_result.grib2

if [ $? -eq 0 ];then
  echo cloudtype/meps success on CPU!
else
  echo cloudtype/meps failed on CPU
  exit 1
fi
rm -f CL*grib2

