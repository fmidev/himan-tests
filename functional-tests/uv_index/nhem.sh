#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f UVIMAX-N_*.grib UVI-N_*.grib

# Real-time input (TotalOzone, snow water-equivalent, surface geopotential)
# is read from nhem-source.grib (auxiliary file). Static climatology files
# (aerosol optical depth, single scattering albedo, disort lookup table) are
# referenced by path in the plugin's JSON options block and loaded directly
# by the plugin. A single run produces both UVIMAX-N (daily-max) and UVI-N
# (instantaneous) into separate grib files (file_write: multiple).

$HIMAN -d 4 -f uv_index_nhem.json --no-cuda nhem-source.grib

ret=0

grib_compare -c values -A 1.5 UVImax_north.grib UVIMAX-N_height_0_ll_361_91_0_012.grib
if [ $? -eq 0 ]; then
	echo uv_index/nhem/max success on CPU!
else
	echo uv_index/nhem/max failed on CPU
	ret=1
fi

grib_compare -c values -A 1.5 UVI_north.grib UVI-N_height_0_ll_361_91_0_012.grib
if [ $? -eq 0 ]; then
	echo uv_index/nhem/instantaneous success on CPU!
else
	echo uv_index/nhem/instantaneous failed on CPU
	ret=1
fi

rm -f UVIMAX-N_*.grib UVI-N_*.grib

exit $ret
