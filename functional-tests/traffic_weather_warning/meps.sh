#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f *m.grib

$HIMAN -d 4 -f meps.json source_meps.grib -s stat --no-cuda

grib_compare fc202411220700+014h00m.grib result_meps.grib

if [ $? -ne 0 ];then
  echo tww/meps failed on CPU
  exit 1
fi

echo tww/meps success on CPU
rm -f *m.grib

