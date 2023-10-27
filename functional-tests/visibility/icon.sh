#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f VV2*.grib2

source_data=visibility_source_icon.grib2

../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f icon.json $source_data

grib_compare VV2-M_height_0_ll_1377_657_0_003.grib2 result_icon.grib2

if [ $? -eq 0 ];then
  echo visibility/icon success!
else
  echo visibility/icon failed
  exit 1
fi

rm -f VV2*.grib2
