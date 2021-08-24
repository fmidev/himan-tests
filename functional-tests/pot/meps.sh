#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f POT-PRCNT*.grib

../../bin/download-if-not-exists.sh pot_source_meps.grib

$HIMAN -d 5 -j 4 -f pot_meps.json pot_source_meps.grib

grib_compare POT-PRCNT_height_0_lcc_889_949_0_003_4_0.grib2 result_meps.grib2

if [ $? -eq 0 ];then
  echo pot/meps success on CPU!
else
  echo pot/meps failed on CPU
  exit 1
fi

rm -f POT-PRCNT*.grib2
