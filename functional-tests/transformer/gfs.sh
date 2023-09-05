#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f tk2tc_gfs.json.grib* tk2tc_gfs.json-CPU.grib*

$HIMAN -d 5 -f tk2tc_gfs.json -t grib2 --no-cuda -s tk2tc_gfs_nocuda gfs_source.grib2

grib_compare -A 0.0001 gfs_result.grib2 tk2tc_gfs.json.grib2

if [ $? -eq 0 ];then
  echo tk2tc/gfs success!
else
  echo tk2tc/gfs failed
  exit 1
fi

if ../../bin/check-for-gpu.sh; then

  mv tk2tc_gfs.json.grib2 tk2tc_gfs.json-CPU.grib2

  $HIMAN -d 5 -f tk2tc_gfs.json -t grib2 -s tk2tc_gfs_cuda gfs_source.grib2

  grib_compare -b totalLength -A 0.0001 tk2tc_gfs.json.grib2 tk2tc_gfs.json-CPU.grib2

  if [ $? -eq 0 ];then
    echo tk2tc/gfs success on GPU!
  else
    echo tk2tc/gfs failed on GPU
    exit 1
  fi
else
  echo "no cuda device found for cuda tests"
fi

rm -f tk2tc_gfs.json.grib* tk2tc_gfs.json-CPU.grib*

