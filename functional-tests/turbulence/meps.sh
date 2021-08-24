#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi
rm turbulence_meps.json.grib*

$HIMAN -d 5 -j 1 -f turbulence_meps.json -t grib --no-cuda source_meps.grib source_meps.grib2

grib_compare -A 1e-5 -R all=1e-3 turbulence_meps.json.grib result_meps.grib

if [ $? -eq 0 ];then
  echo turbulence/meps success on CPU!
else
  echo turbulence/meps failed on CPU
  exit 1
fi
rm turbulence_meps.json.grib*

