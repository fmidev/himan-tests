#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f RR*grib2

$HIMAN -d 5 -f precipitation_meps.json -t grib2 meps_source.grib --no-cuda -s meps_nocuda

grib_compare RR-3-MM_height_0_lcc_949_1069_0_006_4_0.grib2 meps_result_rr3h.grib2

if [ $? -ne 0 ];then
  echo split_sum/meps failed on CPU
  exit 1
fi

grib_compare RR-6-MM_height_0_lcc_949_1069_0_006_4_0.grib2 meps_result_rr6h.grib2

if [ $? -ne 0 ];then
  echo split_sum/meps failed on CPU
  exit 1
fi

grib_compare RRR-KGM2_height_0_lcc_949_1069_0_006_4_0.grib2 meps_result_rrr.grib2

if [ $? -ne 0 ];then
  echo split_sum/meps failed on CPU
  exit 1
fi

echo split_sum/meps success on CPU!
rm -f RR*grib2

