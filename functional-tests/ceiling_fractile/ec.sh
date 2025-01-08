#!/bin/sh
set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f *m.grib

$HIMAN -d 4 -f ec.json source_ec.grib -s stat --no-cuda

grib_compare fc202501061200+006h00m.grib result_ec.grib

if [ $? -ne 0 ];then
  echo ceiling fractile/ec failed on CPU
  exit 1
fi

echo ceiling fractile/ec success on CPU
rm -f *m.grib

