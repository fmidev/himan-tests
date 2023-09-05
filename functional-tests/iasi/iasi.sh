#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f iasi.json.grib2

$HIMAN -d 5 -f iasi.json -t grib2 source.grib --no-cuda

grib_compare result_cpu.grib iasi.json.grib2

if [ $? -eq 0 ];then
  echo iasi success on CPU!
else
  echo iasi failed on CPU
  exit 1
fi

 if ../../bin/check-for-gpu.sh; then

   rm -f iasi.json.grib2

   $HIMAN -d 5 -f iasi.json -t grib2 source.grib

   grib_compare -A 0.1 result_gpu.grib iasi.json.grib2

   if [ $? -eq 0 ];then
     echo iasi success on GPU!
   else
     echo iasi failed on GPU
     exit 1
   fi
else
  echo "no cuda device found for cuda tests"
fi

rm -f iasi.json.grib2
