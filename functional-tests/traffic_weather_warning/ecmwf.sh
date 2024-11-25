#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f *m.grib

$HIMAN -d 4 -f ecmwf.json source_ecmwf.grib -s stat --no-cuda

grib_compare fc202411220700+080h00m.grib result_ecmwf.grib

if [ $? -ne 0 ];then
  echo tww/ecmwf failed on CPU
  exit 1
fi

echo tww/ecmwf success on CPU
rm -f *m.grib

