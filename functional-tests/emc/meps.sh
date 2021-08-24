#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
  export HIMAN="../../himan-bin/himan"
fi

rm -f ENSMEM*grib2

$HIMAN -s no-cuda -d 4 -f meps.json meps_source.grib --no-cuda

num=$(grib_get -p average ./ENSMEMB-N_height_2_lcc_949_1069_0_003_5.grib2)

if [ $num -eq 30 ]; then
  echo "emc/meps success on CPU"
else
  echo "emc/meps failed on CPU"
  exit 1
fi

rm -f ENSMEM*grib2

