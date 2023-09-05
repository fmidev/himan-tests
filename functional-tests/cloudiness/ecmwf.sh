#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f N-PRCNT*

../../bin/download-if-not-exists.sh cloudiness_ecmwf_source.grib.bz2

$HIMAN -d 4 -f ecmwf.json cloudiness_ecmwf_source.grib.bz2 --no-cuda

grib_compare ./N-PRCNT_height_0_rll_201_221_0_144.grib ecmwf_result.grib

echo cloudiness/ecmwf success on CPU!

if [ ../../bin/check-for-gpu.sh ]; then
  rm -f N-PRCNT*

  $HIMAN -d 4 -f ecmwf.json cloudiness_ecmwf_source.grib.bz2

  grib_compare ./N-PRCNT_height_0_rll_201_221_0_144.grib ecmwf_result.grib

  echo cloudiness/ecmwf success on GPU!
fi

rm -f N*-PRCNT*

