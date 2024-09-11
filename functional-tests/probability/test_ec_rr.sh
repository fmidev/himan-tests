#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm ./PROB-RR24-1_ground_0_rll_331_289_0_0{12,24}*.grib2

$HIMAN -d 4 -f ec_rr.json --no-cuda ec_rr_source.grib

grib_compare -b referenceValue -A 0.001 ./PROB-RR24-1_ground_0_rll_331_289_0_012_5.grib2  ec_rr_12_result.grib

if [ $? -ne 0 ]; then
	echo probability/ec_rr failed on CPU!
	exit 1
fi

grib_compare -b referenceValue -A 0.001 ./PROB-RR24-1_ground_0_rll_331_289_0_024_5.grib2 ec_rr_24_result.grib

if [ $? -eq 0 ]; then
	echo probability/ec_rr success on CPU!
else
	echo probability/ec_rr failed on CPU!
	exit 1
fi

rm ./PROB-RR24-1_ground_0_rll_331_289_0_0{12,24}*.grib2

