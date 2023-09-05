#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f TSEA*.grib

$HIMAN -d 5 -f ec_tsea.json -t grib --no-cuda -s tsea ec_tsea_source.grib --no-auxiliary-file-full-cache-read

grib_compare -A 0.0001 ec_tsea_result.grib TSEA-K_ground_0_rll_161_177_0_003.grib

if [ $? -eq 0 ];then
  echo transformer_lsm/ec success!
else
  echo transformer_lsm/ec failed
  exit 1
fi

if ../../bin/check-for-gpu.sh; then

  rm -f TSEA*.grib

  $HIMAN -d 5 -f ec_tsea.json -t grib -s tsea ec_tsea_source.grib --no-auxiliary-file-full-cache-read

  grib_compare -A 0.0001 ec_tsea_result.grib TSEA-K_ground_0_rll_161_177_0_003.grib

  if [ $? -eq 0 ];then
    echo transformer_lsm/ec success on GPU!
  else
    echo transformer_lsm/ec failed on GPU
    exit 1
  fi
else
  echo "no cuda device found for cuda tests"
fi

rm -f TSEA*.grib

