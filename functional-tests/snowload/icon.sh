#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f SNOWLOAD-KGM2_height_0_ll_1377_657_0_081.grib2

$HIMAN -d 4 -f snowload_icon.json -t grib source_icon.grib2

grib_compare SNOWLOAD-KGM2_height_0_ll_1377_657_0_081.grib2 result_icon.grib2
if [ $? -eq 0 ];then
  echo snowload/icon success on CPU!
else
  echo snowload/icon failed on CPU
  exit 1
fi

rm -f SNOWLOAD-KGM2_height_0_ll_1377_657_0_081.grib2
