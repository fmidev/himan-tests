#!/bin/sh
set -x

if [ -z "$HIMAN" ]; then
        export HIMAN="../../himan-bin/himan"
fi

rm -f *m.grib

$HIMAN -d 4 -f vire.json source.grib -s stat --no-cuda

grib_compare fc202606080700+015h00m.grib result.grib

if [ $? -ne 0 ];then
  echo precipiation-limit-values.lua failed on CPU
  exit 1
fi

echo precipitation-limit-values.lua success on CPU
rm -f *m.grib
