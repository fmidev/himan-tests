#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
        export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f fc*.grib2

$HIMAN -d 4 -f meps.json -t grib2 --no-cuda meps_source.grib

grib_compare fc202605060300+001h00m.grib2 meps_result.grib2
if [ $? -eq 0 ];then
  echo smartsymbol/meps success on CPU!
else
  echo smartsymbol/meps failed on CPU
  exit 1
fi

rm -f fc*.grib2
