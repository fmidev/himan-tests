#!/bin/sh

set -xeu

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f WEATHER* SMARTSY* HESSAA* HSADE*

$HIMAN -d 4 -f ecmwf.json ecmwf_source.grib --no-cuda

grib_compare HSADE1-N_height_0_ll_3600_1801_0_004.grib ecmwf_result.grib

echo hsade1/ecmwf success on CPU!

rm -f WEATHER* SMARTSY* HESSAA* HSADE*

