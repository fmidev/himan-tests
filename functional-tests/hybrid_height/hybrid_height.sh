#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f HL-M_*

$HIMAN -d 5 -f hybrid_height.json hl_source_geop.grib --no-cuda -s stat

grib_compare result.grib HL-M_hybrid_64_polster_290_225_0_003.grib

if [ $? -eq 0 ];then
  echo hybrid_height/hirlam success on cpu!
else
  echo hybrid_height/hirlam failed on cpu
  exit 1
fi

if [ ../../bin/check-for-gpu.sh ]; then
  rm -f HL-M_*

  $HIMAN -d 5 -f hybrid_height.json -t grib hl_source_geop.grib -s stat

  grib_compare -b referenceValue -A 0.2 result.grib HL-M_hybrid_64_polster_290_225_0_003.grib

  if [ $? -eq 0 ];then
    echo hybrid_height/hirlam success on gpu!
  else
    echo hybrid_height/hirlam failed on gpu
    exit 1
  fi

fi

rm -f HL-M_*
