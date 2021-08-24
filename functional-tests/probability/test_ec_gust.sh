#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm ec_gust.json.grib

$HIMAN -d 5 -f ec_gust.json --no-cuda ec_gust_source.grib

grib_compare -A 0.001 ec_gust.json.grib ec_gust_result.grib
if [ $? -eq 0 ]; then
	echo probability/ec_gust success on CPU!
else
	echo probability/ec_gust failed on CPU!
	exit 1
fi

rm ec_gust.json.grib
