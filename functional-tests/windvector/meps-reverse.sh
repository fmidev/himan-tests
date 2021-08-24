#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f U-MS* V-MS* DF-MS*

$HIMAN -d 5 -f windvector_meps_reverse.json meps_reverse_source.grib2 -s meps_nocuda --no-cuda 

grib_compare -A 1 meps_result_u.grib2 U-MS_height_10_lcc_949_1069_0_006_4_0.grib2

if [ $? -eq 0 ];then
  echo windvector/meps_reverse u vector success!
else
  echo windvector/meps_reverse u vector failed
  exit 1
fi

grib_compare -A 1 meps_result_df.grib2 DF-MS_height_10_lcc_949_1069_0_006_4_0.grib2

if [ $? -eq 0 ];then
  echo windvector/meps_reverse wind vector success!
else
  echo windvector/meps_reverse wind vector failed
  exit 1
fi

rm -f U-MS* V-MS* DF-MS*
