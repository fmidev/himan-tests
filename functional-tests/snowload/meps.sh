#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f snowload_meps.json.grib

$HIMAN -d 4 -f snowload_meps.json -t grib source.grib

grib_compare snowload_meps.json.grib result.grib2
if [ $? -eq 0 ];then
  echo snowload/meps success on CPU!
else
  echo snowload/meps failed on CPU
  exit 1
fi

rm -f snowload_meps.json.grib
