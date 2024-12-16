#!/bin/sh
set -x

if [ -z "$HIMAN" ]; then
        export HIMAN="../../himan-bin/himan"
fi

rm -f *m.grib

$HIMAN -d 4 -f vire.json source.grib -s stat --no-cuda

grib_compare fc202412131300+015h00m.grib result.grib

if [ $? -ne 0 ];then
  echo precipiation check failed on CPU
  exit 1
fi

echo precipitation check success on CPU
rm -f *m.grib
