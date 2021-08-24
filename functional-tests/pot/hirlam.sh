#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f POT-PRCNT*.grib

../../bin/download-if-not-exists.sh pot_source_hirlam.grib

$HIMAN -d 5 -j 4 -f pot_hirlam.json pot_source_hirlam.grib

grib_compare POT-PRCNT_height_0_rll_1030_816_0_003.grib result_hirlam.grib

if [ $? -eq 0 ];then
  echo pot/hirlam success on CPU!
else
  echo pot/hirlam failed on CPU
  exit 1
fi

rm -f POT-PRCNT*.grib
