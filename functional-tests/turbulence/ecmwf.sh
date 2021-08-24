#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm turbulence_ec.json.grib*

$HIMAN -d 5 -j 1 -f turbulence_ec.json -t grib --no-cuda source_ec.grib2

grib_compare turbulence_ec.json.grib result_ec.grib

if [ $? -eq 0 ];then
  echo turbulence/ecmwf success on CPU!
else
  echo turbulence/ecmwf failed on CPU
  exit 1
fi
rm turbulence_ec.json.grib*

