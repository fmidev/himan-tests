#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f PROB*grib2

# Valid configuration: compare output to an independent numpy calculation of the same probabilities
$HIMAN -d 5 -f meps_conditions.json --no-cuda meps_conditions_source.grib

python3 check_conditions.py meps_conditions_source.grib

if [ $? -ne 0 ]; then
	echo probability/conditions failed on CPU!
	exit 1
fi

# The flat form and an empty conditions array must be identical
grib_compare -c data:n PROB-RR-7_height_0_lcc_889_949_0_048_5.grib2 PROB-RR3-6_height_0_lcc_889_949_0_048_5.grib2

if [ $? -ne 0 ]; then
	echo probability/conditions empty conditions array differs from flat form!
	exit 1
fi

rm -f PROB*grib2

echo probability/conditions success on CPU!
