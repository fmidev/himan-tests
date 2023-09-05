#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f H0C-M_*

../../bin/download-if-not-exists.sh ncl_source_ec.grib.bz2

$HIMAN -d 5 -f ec.json -t grib ncl_source_ec.grib.bz2 -s stat --no-cuda

grib_compare ec_result.grib ./H0C-M_height_0_rll_465_461_0_003.grib 

if [ $? -eq 0 ];then
  echo ncl/ec success on CPU!
else
  echo ncl/ec failed on CPU
  exit 1
fi

if [ ../../bin/check-for-gpu.sh ]; then

  rm -f H0C-M_*

  $HIMAN -d 5 -f ec.json -t grib ncl_source_ec.grib.bz2 -s stat

  grib_compare ec_result.grib ./H0C-M_height_0_rll_465_461_0_003.grib 

  if [ $? -eq 0 ];then
    echo ncl/ec success on GPU!
  else
    echo ncl/ec failed on GPU
    exit 1
  fi

fi

rm -f H0C-M_*

