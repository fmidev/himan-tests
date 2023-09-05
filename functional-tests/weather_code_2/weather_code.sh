#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f weather_symbol_hir1h.json.grib weather_symbol_ecmwf.json.grib

$HIMAN -d 4 -f weather_symbol_hir1h.json -t grib hir1h_source/11_100_850_0_10_1030_816_0_001.grib hir1h_source/11_105_0_0_10_1030_816_0_001.grib hir1h_source/71_105_0_0_10_1030_816_0_001.grib hir1h_source/73_105_0_0_10_1030_816_0_001.grib hir1h_source/74_105_0_0_10_1030_816_0_001.grib hir1h_source/75_105_0_0_10_1030_816_0_001.grib hir1h_source/CLDSYM-N_height_0_rll_1030_816_0_001.grib hir1h_source/FOGSYM-N_height_0_rll_1030_816_0_001.grib hir1h_source/KINDEX-N_height_0_rll_1030_816_0_001.grib hir1h_source/PRECFORM-N_height_0_rll_1030_816_0_001.grib hir1h_source/RRR-KGM2_height_0_rll_1030_816_0_001.grib --no-cuda -s stat

grib_compare hir1h_result.grib weather_symbol_hir1h.json.grib

if [ $? -eq 0 ];then
  echo weather_code_2/hirlam success on CPU!
else
  echo weather_code_2/hirlam failed on CPU
  exit 1
fi

if ../../bin/check-for-gpu.sh; then

  rm -f weather_symbol_hir1h.json.grib weather_symbol_ecmwf.json.grib

  $HIMAN -d 4 -f weather_symbol_hir1h.json -t grib hir1h_source/11_100_850_0_10_1030_816_0_001.grib hir1h_source/11_105_0_0_10_1030_816_0_001.grib hir1h_source/71_105_0_0_10_1030_816_0_001.grib hir1h_source/73_105_0_0_10_1030_816_0_001.grib hir1h_source/74_105_0_0_10_1030_816_0_001.grib hir1h_source/75_105_0_0_10_1030_816_0_001.grib hir1h_source/CLDSYM-N_height_0_rll_1030_816_0_001.grib hir1h_source/FOGSYM-N_height_0_rll_1030_816_0_001.grib hir1h_source/KINDEX-N_height_0_rll_1030_816_0_001.grib hir1h_source/PRECFORM-N_height_0_rll_1030_816_0_001.grib hir1h_source/RRR-KGM2_height_0_rll_1030_816_0_001.grib -s stat

  grib_compare hir1h_result.grib weather_symbol_hir1h.json.grib

  if [ $? -eq 0 ];then
    echo weather_code_2/hirlam success on GPU!
  else
    echo weather_code_2/hirlam failed on GPU
    exit 1
  fi

fi

$HIMAN -d 4 -f weather_symbol_ecmwf.json -t grib ECMWF_source/19_105_0_0_10_161_177_0_001.grib ECMWF_source/130_100_850_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/164_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/167_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/186_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/187_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/188_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/CLDSYM-N_height_0_ll_2880_1441_0_001.grib ECMWF_source/KINDEX-N_height_0_ll_2880_1441_0_001.grib ECMWF_source/PRECFORM-N_height_0_ll_2880_1441_0_001.grib ECMWF_source/RRR-KGM2_height_0_ll_2880_1441_0_001.grib --no-cuda -s stat

grib_compare ecmwf_result.grib weather_symbol_ecmwf.json.grib

if [ $? -eq 0 ];then
  echo weather_code_2/ecmwf success on CPU!
else
  echo weather_code_2/ecmwf failed on CPU
  exit 1
fi

if ../../bin/check-for-gpu.sh; then
  rm -f weather_symbol_ecmwf.json.grib

  $HIMAN -d 4 -f weather_symbol_ecmwf.json -t grib ECMWF_source/19_105_0_0_10_161_177_0_001.grib ECMWF_source/130_100_850_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/164_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/167_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/186_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/187_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/188_1_0_0_rll_161_177_0_001_1_9_0.grib ECMWF_source/CLDSYM-N_height_0_ll_2880_1441_0_001.grib ECMWF_source/KINDEX-N_height_0_ll_2880_1441_0_001.grib ECMWF_source/PRECFORM-N_height_0_ll_2880_1441_0_001.grib ECMWF_source/RRR-KGM2_height_0_ll_2880_1441_0_001.grib --no-cuda -s stat

  grib_compare ecmwf_result.grib weather_symbol_ecmwf.json.grib

  if [ $? -eq 0 ];then
    echo weather_code_2/ecmwf success on GPU!
  else
    echo weather_code_2/ecmwf failed on GPU
    exit 1
  fi

fi

rm -f weather_symbol_hir1h.json.grib weather_symbol_ecmwf.json.grib

