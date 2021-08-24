#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f KINDEX-N* VTI-N* CTI-N* TTI-N*

../../bin/download-if-not-exists.sh stability-hirlam-full-source.grib

$HIMAN -d 4 -f hirlam-all.json --no-cuda -s hirlam-stat -t grib  stability-hirlam-full-source.grib

grib_compare hirlam-result-kindex.grib KINDEX-N_height_0_rll_1030_816_0_010.grib

if [ $? -ne 0 ];then
  echo stability/hirlam failed on CPU
  exit 1
fi

#grib_compare hirlam-result-si.grib SI-N_height_0_rll_1030_816_0_010.grib

#if [ $? -ne 0 ];then
#  echo stability/hirlam failed on CPU
#  exit 1
#fi

#grib_compare hirlam-result-li.grib LI-N_height_0_rll_1030_816_0_010.grib

#if [ $? -ne 0 ];then
#  echo stability/hirlam failed on CPU
#  exit 1
#fi

grib_compare hirlam-result-vti.grib VTI-N_height_0_rll_1030_816_0_010.grib

if [ $? -ne 0 ];then
  echo stability/hirlam failed on CPU
  exit 1
fi

grib_compare hirlam-result-cti.grib CTI-N_height_0_rll_1030_816_0_010.grib

if [ $? -ne 0 ];then
  echo stability/hirlam failed on CPU
  exit 1
fi

grib_compare hirlam-result-tti.grib TTI-N_height_0_rll_1030_816_0_010.grib

if [ $? -eq 0 ];then
  echo stability/hirlam success on CPU!
else
  echo stability/hirlam failed on CPU
  exit 1
fi

if [ $(/sbin/lsmod | egrep -c "^nvidia") -gt 0 ]; then

  rm -f *-N_height*010.grib

  $HIMAN -d 4 -f hirlam-all.json -t grib -s hirlam-all-cuda stability-hirlam-full-source.grib

  grib_compare hirlam-result-kindex.grib KINDEX-N_height_0_rll_1030_816_0_010.grib

  if [ $? -ne 0 ];then
    echo stability/hirlam failed on GPU
    exit 1
  fi

#grib_compare hirlam-result-si.grib SI-N_height_0_rll_1030_816_0_010.grib

#if [ $? -ne 0 ];then
#  echo stability/hirlam failed on CPU
#  exit 1
#fi

#grib_compare hirlam-result-li.grib LI-N_height_0_rll_1030_816_0_010.grib

#if [ $? -ne 0 ];then
#  echo stability/hirlam failed on CPU
#  exit 1
#fi

  grib_compare hirlam-result-vti.grib VTI-N_height_0_rll_1030_816_0_010.grib

  if [ $? -ne 0 ];then
    echo stability/hirlam failed on GPU
    exit 1
  fi

  grib_compare hirlam-result-cti.grib CTI-N_height_0_rll_1030_816_0_010.grib

  if [ $? -ne 0 ];then
    echo stability/hirlam failed on GPU
    exit 1
  fi

  grib_compare hirlam-result-tti.grib TTI-N_height_0_rll_1030_816_0_010.grib

  if [ $? -eq 0 ];then
    echo stability/hirlam success on GPU!
  else
    echo stability/hirlam failed on GPU
    exit 1
  fi

else
  echo "no cuda device found for cuda tests"
fi

rm -f KINDEX-N* VTI-N* CTI-N* TTI-N*

