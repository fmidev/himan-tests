#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
  export HIMAN="../../himan-bin/himan"
fi

../../bin/download-if-not-exists.sh updraft-helicity_meps_source.grib

rm -f UHEL*grib2

$HIMAN -s no-cuda -d 4 -f meps.json updraft-helicity_meps_source.grib --no-cuda

grib_compare UHEL-M2S2_height_0_lcc_949_1069_0_003_4_0.grib2 meps_result.grib2

if [ $? -eq 0 ];then
  echo updraft-helicity/meps success on CPU!
else
  echo updraft-helicity/meps failed on CPU
  exit 1
fi
rm -f UHEL*grib2

