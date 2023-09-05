#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f IDD-D*.grib IFF-MS*.grib

$HIMAN -j 1 -d 5 -f windvector_helmi.json -t grib windvector_helmi_source.grib --no-cuda -s helmi_nocuda

grib_compare -A 0.01 helmi_result_IFF.grib IFF-MS_ground_0_ll_415_556_0_010.grib

if [ $? -eq 0 ];then
  echo windvector/helmi ice speed success on CPU!
else
  echo windvector/helmi ice speed failed on CPU
  exit 1
fi

grib_compare -A 1 helmi_result_IDD.grib IDD-D_ground_0_ll_415_556_0_010.grib

if [ $? -eq 0 ];then
  echo windvector/helmi ice direction success on CPU!
else
  echo windvector/helmi ice direction failed on CPU
  exit 1
fi

if ../../bin/check-for-gpu.sh; then

  rm -f IDD-D*.grib IFF-MS*.grib

  $HIMAN -d 5 -f windvector_helmi.json -t grib windvector_helmi_source.grib -s helmi_cuda

  grib_compare -A 0.001 helmi_result_IFF.grib IFF-MS_ground_0_ll_415_556_0_010.grib

  if [ $? -eq 0 ];then
    echo windvector/helmi ice speed success on GPU!
  else
    echo windvector/helmi ice speed failed on GPU
    exit 1
  fi

  grib_compare -A 1 helmi_result_IDD.grib IDD-D_ground_0_ll_415_556_0_010.grib

  if [ $? -eq 0 ];then
    echo windvector/helmi ice direction success on GPU!
  else
    echo windvector/helmi ice direction failed on GPU
    exit 1
  fi
fi

rm -f IDD-D*.grib IFF-MS*.grib

