#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f RR*grib

$HIMAN -d 5 -f precipitation_harmonie.json -t grib harmonie_source.grib --no-cuda -s harmonie_nocuda

grib_compare harmonie_result_1_60.grib RR-1-MM_height_0_rll_290_594_0_001.grib

if [ $? -ne 0 ];then
  echo precipitation/harmonie failed on CPU
  exit 1
fi

grib_compare harmonie_result_1_120.grib RR-1-MM_height_0_rll_290_594_0_002.grib

if [ $? -ne 0 ];then
  echo precipitation/harmonie failed on CPU
  exit 1
fi

grib_compare harmonie_result_1_180.grib RR-1-MM_height_0_rll_290_594_0_003.grib

if [ $? -ne 0 ];then
  echo precipitation/harmonie failed on CPU
  exit 1
fi

grib_compare harmonie_result_3_180.grib RR-3-MM_height_0_rll_290_594_0_003.grib

if [ $? -eq 0 ];then
  echo precipitation/harmonie success on CPU!
else
  echo precipitation/harmonie failed on CPU
  exit 1
fi

rm -f RADGLO*

$HIMAN -d 5 -f radiation_harmonie.json -t grib ./harmonie_source_rad.grib --no-cuda -s harmonie_nocuda

grib_compare harmonie_result_radglo_60.grib RADGLO-WM2_height_0_rll_720_800_0_001.grib

if [ $? -ne 0 ];then
  echo radiation/harmonie failed on CPU
  exit 1
fi

grib_compare harmonie_result_radglo_75.grib RADGLO-WM2_height_0_rll_720_800_0_001h15min.grib2

if [ $? -eq 0 ];then
  echo radiation/harmonie success on CPU!
else
  echo radiation/harmonie failed on CPU
  exit 1
fi

rm -f RADSW*

$HIMAN -d 5 -f radiation_harmonie_sw.json -t grib ./harmonie_source_rad.grib --no-cuda -s harmonie_nocuda

grib_compare harmonie_result_radsw.grib RADSW-WM2_height_0_rll_720_800_0_048.grib

if [ $? -ne 0 ];then
  echo radiation/harmonie failed on CPU
  exit 1
fi

rm -f RR*grib RADSW* RADGLO* 

