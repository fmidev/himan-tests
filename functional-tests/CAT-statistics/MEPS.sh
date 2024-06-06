#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f fc*.grib2

../../bin/download-if-not-exists.sh CAT-statistics_meps_source.grib
 
$HIMAN -d 5 -f CAT_statistics_meps.json -t grib2 --no-cuda CAT-statistics_meps_source.grib

grib_compare fc202406030000+001h00m.grib2 result_meps.grib2

if [ $? -eq 0 ];then
  echo CAT-statistics/MEPS success on CPU!
else
  echo CAT-statistics/MEPS failed on CPU
  exit 1
fi

rm -f fc*.grib2
