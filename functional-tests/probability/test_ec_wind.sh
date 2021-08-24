#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm  ec_wind.json.grib

$HIMAN -d 5 -f ec_wind.json --no-cuda ec_wind_source.grib

grib_compare -A 0.001 ec_wind.json.grib ec_wind_result.grib
if [ $? -eq 0 ]; then
	echo probability/ec_wind success on CPU!
else
	echo probability/ec_wind failed on CPU!
	exit 1
fi

rm ec_wind.json.grib
