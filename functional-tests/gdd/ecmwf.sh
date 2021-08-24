#!/bin/sh

set -x
if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f GDD*.grib

$HIMAN -d 4 -f ecmwf.json source_ecmwf.grib -s stat --no-cuda

grib_compare ./GDD-C_height_2_ll_3600_1801_0_048.grib result_ecmwf.grib

if [ $? -ne 0 ];then
  echo gdd/ecmwf failed on CPU
  exit 1
fi

echo gdd/ecmwf success on CPU
rm -f GDD*.grib

