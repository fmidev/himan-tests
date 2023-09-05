#!/bin/sh
# disable test until new himan version is in production
# (required source P field is missing full AB information)
exit 0 
set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f RH-PRCNT_hybrid*

$HIMAN -d 5 -f relative_humidity_hybrid_ecmwf.json -t grib --no-cuda source_ecmwf_hybrid.grib

grib_compare RH-PRCNT_hybrid_137_rll_161_177_0_001.grib2 result_ecmwf_hybrid.grib2 

if [ $? -eq 0 ];then
  echo relative humidity_hybrid/ecmwf success on CPU!
else
  echo relative humidity_hybrid/ecmwf failed on CPU
  exit 1
fi

if ../../bin/check-for-gpu.sh; then

  rm -f RH-PRCNT_hybrid*

  $HIMAN -s cuda -d 5 -f relative_humidity_hybrid_ecmwf.json -t grib source_ecmwf_hybrid.grib

  grib_compare -b referenceValue -A 0.01 RH-PRCNT_hybrid_137_rll_161_177_0_001.grib2 result_ecmwf_hybrid.grib2 

  if [ $? -eq 0 ];then
    echo relative_humidity_hybrid/ecmwf success on GPU!
  else
    echo relative_humidity_hybrid/ecmwf failed on GPU
  fi
else
  echo "no cuda device found for cuda tests"
fi
