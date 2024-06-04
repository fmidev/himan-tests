#!/bin/sh

set -ex

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f maxmin.json.grib 

$HIMAN -d 5 -f maxmin.json -t grib --no-cuda -s maxmin_nocuda ec_source.grib

v=$(grib_get -p minimum maxmin.json.grib)

if [ $v -ne 260 ];then
  echo min value is not 260
  exit 1
fi

v=$(grib_get -p maximum maxmin.json.grib)

if [ $v -ne 265 ];then
  echo max value is not 265
  exit 1
fi

echo maxmin success on CPU!

if ../../bin/check-for-gpu.sh; then

  rm -f maxmin.json.grib

  $HIMAN -d 5 -f maxmin.json -t grib -s maxmin_cuda ec_source.grib

  v=$(grib_get -p minimum maxmin.json.grib)

  if [ $v -ne 260 ];then
    echo min value is not 260
    exit 1
  fi

  v=$(grib_get -p maximum maxmin.json.grib)

  if [ $v -ne 265 ];then
    echo max value is not 265
    exit 1
  fi

  echo maxmin success on GPU!

else
  echo "no cuda device found for cuda tests"
fi

rm -f maxmin.json.grib
