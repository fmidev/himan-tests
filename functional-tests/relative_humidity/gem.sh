#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f RH-PRCNT_pressure_700_ll_1500_751_0_006.grib

$HIMAN -d 5 -j 1 -f relative_humidity_gem.json --no-cuda source_gem.grib

grib_compare -A 0.01 RH-PRCNT_pressure_700_ll_1500_751_0_006.grib result_gem.grib 

if [ $? -ne 0 ];then
  echo relative humidity/gem failed on CPU
  exit 1
else
  echo relative humidity/gem success on CPU
fi

if ../../bin/check-for-gpu.sh; then

  rm -f RH-PRCNT_pressure_700_ll_1500_751_0_006.grib

  $HIMAN -s cuda -d 5 -f relative_humidity_gem.json -t grib source_gem.grib

  grib_compare -b referenceValue -A 0.01 RH-PRCNT_pressure_700_ll_1500_751_0_006.grib result_gem.grib

  if [ $? -ne 0 ];then
    echo relative_humidity/gem failed on GPU
  else
    echo relative humidity/gem success on GPU
  fi

else
  echo "no cuda device found for cuda tests"
fi
rm -f RH-PRCNT_pressure_700_ll_1500_751_0_006.grib

