#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f uv_index_anomaly_europe.json.grib

# Total-ozone forecast (TOZONE-KGM2) is fetched from radon. The static TOMS
# climatology (5 Fourier coefficients per 1°x1° cell) is referenced by path
# in the plugin's JSON options block.

$HIMAN -d 4 -f uv_index_anomaly_europe.json --no-cuda ozone-source.grib

grib_compare -c values -A 0.5 OtsoniAnomalia_europe.grib uv_index_anomaly_europe.json.grib

if [ $? -eq 0 ]; then
	echo uv_index/europe/anomaly success on CPU!
else
	echo uv_index/europe/anomaly failed on CPU
	exit 1
fi

rm -f uv_index_anomaly_europe.json.grib
