#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f PRE*N.grib2

$HIMAN -t grib2 -d 4 -f smartmet.json smartmet_source.grib2 --no-cuda -s

grib_compare smartmet_pref_result.grib2 ./PRECFORM2-N_height_0_polster_270_300_0_016.grib2
grib_compare smartmet_pret_result.grib2 ./PRECTYPE-N_height_0_polster_270_300_0_016.grib2

rm -f PRE*N.grib2

