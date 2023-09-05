#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
  export HIMAN="../../himan-bin/himan"
fi

rm -f *lcc*grib2

../../bin/download-if-not-exists.sh neighborhood_probability_meps_source.grib

$HIMAN -s no-cuda -d 4 -f meps.json neighborhood_probability_meps_source.grib --no-cuda

grib_compare ./PROB-WG-AGG-1_height_10_lcc_889_949_0_006_5.grib2 meps_result.grib2

if [ $? -eq 0 ]; then
  echo "neighborhood prob/meps success on CPU"
else
  echo "neighborhood prob/meps failed on CPU"
  exit 1
fi

if [ ../../bin/check-for-gpu.sh ]; then
  rm -f *lcc*grib2

  $HIMAN -s cuda -d 4 -f meps.json neighborhood_probability_meps_source.grib

  grib_compare ./PROB-WG-AGG-1_height_10_lcc_889_949_0_006_5.grib2 meps_result.grib2

  if [ $? -eq 0 ]; then
    echo "neighborhood prob/meps success on GPU"
  else
    echo "neighborhood prob/meps failed on GPU"
    exit 1
  fi
fi

rm -f *lcc*grib2
