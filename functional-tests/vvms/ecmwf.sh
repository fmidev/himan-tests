#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f VV-*.grib

$HIMAN -d 5 -f vvms_ec.json -t grib -s vvms_ec_nocuda ec_t.grib ec_vv.grib --no-cuda

grib_compare -A 0.0001 VV-MS.grib ec_result.grib

if [ $? -ne 0 ];then
  echo vvms/ec failed
  exit 1
fi

$HIMAN -d 5 -f vvms_ec_reverse.json -t grib -s vvms_ec_nocuda ec_t.grib VV-MS.grib --no-cuda

grib_compare -A 0.0001 -c values VV-PAS.grib ec_vv.grib

if [ $? -eq 0 ];then
  echo vvms/ec success!
else
  echo vvms/ec failed
  exit 1
fi


if ../../bin/check-for-gpu.sh; then

  rm -f VV-*.grib

  $HIMAN -d 5 -f vvms_ec.json -t grib -s vvms_ec_cuda ec_t.grib ec_vv.grib

  grib_compare -b referenceValue -A 0.0001 VV-MS.grib ec_result.grib

  if [ $? -ne 0 ];then
    echo vvms/ec failed on GPU
    exit 1
  fi

  $HIMAN -d 5 -f vvms_ec_reverse.json -t grib -s vvms_ec_cuda ec_t.grib VV-MS.grib

  grib_compare -c values -A 0.0001 VV-PAS.grib ec_vv.grib

  if [ $? -eq 0 ];then
    echo vvms/ec success on GPU!
  else
    echo vvms/ec failed on GPU
    exit 1
  fi

else
  echo "no cuda device found for cuda tests"
fi

rm -f VV-*.grib
