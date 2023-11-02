#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f PROB*grib2

$HIMAN -d 5 -f meps_preform.json --no-cuda meps_preform_source.grib

grib_compare ./PROB-FRRAIN_height_0_lcc_889_949_0_048_5.grib2 meps_frrain_result.grib

if [ $? -ne 0 ]; then
	echo probability/meps failed on CPU!
	exit 1
fi

grib_compare ./PROB-RAIN_height_0_lcc_889_949_0_048_5.grib2 meps_rain_result.grib

if [ $? -ne 0 ]; then
	echo probability/meps failed on CPU!
	exit 1
fi

$HIMAN -d 5 -f meps_t.json --no-cuda meps_t_source.grib

grib_compare -A 0.1 ./PROB-TC-0_height_2_lcc_889_949_0_032_5.grib2 meps_tc0_result.grib

if [ $? -ne 0 ]; then
	echo probability/meps failed on CPU!
	exit 1
fi

grib_compare -A 0.1 ./PROB-TC-1_height_2_lcc_889_949_0_032_5.grib2 meps_tc1_result.grib

if [ $? -ne 0 ]; then
	echo probability/meps failed on CPU!
	exit 1
fi

$HIMAN -d 5 -f meps_cl.json --no-cuda meps_cl_source.grib

grib_compare -A 0.1 PROB-CEIL-1_height_0_lcc_889_949_0_032_5.grib2 meps_cl_result.grib

if [ $? -ne 0 ]; then
	echo probability/meps failed on CPU!
	exit 1
fi

echo probability/meps success on CPU!

rm -f PROB*grib2

