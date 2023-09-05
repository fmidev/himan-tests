#!/bin/sh

set -ex

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f U-MS_hybrid_65_lcc*grib2 V-MS_hybrid_65_lcc*grib2

$HIMAN -d 5 -f rotation.json -t grib2 --no-cuda source-rotation.grib2 -s

grib_compare result-rotation-u.grib2 U-MS_hybrid_65_lcc_949_1069_0_006.grib2
grib_compare result-rotation-v.grib2 V-MS_hybrid_65_lcc_949_1069_0_006.grib2

echo rotation success for CPU

set +e

if ../../bin/check-for-gpu.sh; then

  set -e
  rm -f U-MS_hybrid_65_lcc*grib2 V-MS_hybrid_65_lcc*grib2

  $HIMAN -d 5 -f rotation.json -t grib2 source-rotation.grib2 -s

  grib_compare result-rotation-u.grib2 U-MS_hybrid_65_lcc_949_1069_0_006.grib2
  grib_compare result-rotation-v.grib2 V-MS_hybrid_65_lcc_949_1069_0_006.grib2

  echo rotation success on GPU!
else
  echo "no cuda device found for cuda tests"
fi

rm -f U-MS_hybrid_65_lcc*grib2 V-MS_hybrid_65_lcc*grib2


