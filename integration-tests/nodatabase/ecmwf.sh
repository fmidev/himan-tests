#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f DD-D*.grib FF-MS*.grib DF-MS*.grib

$HIMAN -d 5 -f ecmwf.json --no-database --no-cuda -s ec_nocuda ecmwf_source.grib --param-file param-file.txt

grib_compare -A 0.01 ecmwf-ff-ms.grib FF-MS_ground_0_ll_100_200_0_006.grib

if [ $? -ne 0 ];then
  echo nodatabase/ec failed on CPU
  exit 1
fi

grib_compare -A 1 ecmwf-dd-d.grib DD-D_ground_0_ll_100_200_0_006.grib

if [ $? -eq 0 ];then
  echo nodatabase/ec success on CPU!
else
  echo nodatabase/ec failed on CPU
  exit 1
fi

if [ $(/sbin/lsmod | egrep -c "^nvidia") -gt 0 ]; then

  rm -f DD-D*.grib FF-MS*.grib DF-MS*.grib

  $HIMAN -d 5 -f ecmwf.json --no-database --no-cuda -s ec_nocuda ecmwf_source.grib --param-file param-file.txt

  grib_compare -A 0.01 ecmwf-ff-ms.grib FF-MS_ground_0_ll_100_200_0_006.grib

  if [ $? -ne 0 ];then
    echo nodatabase/ec failed on GPU
    exit 1
  fi

  grib_compare -A 1 ecmwf-dd-d.grib DD-D_ground_0_ll_100_200_0_006.grib

  if [ $? -eq 0 ];then
    echo nodatabase/ec success on GPU!
  else
    echo nodatabase/ec failed on GPU
    exit 1
  fi

fi
