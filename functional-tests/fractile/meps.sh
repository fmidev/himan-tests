#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f meps-fractile-lagged.json.grib2

$HIMAN -s no-cuda -d 4 -f meps-fractile-lagged.json meps_source.grib --no-cuda

grib_compare -r meps_result.grib meps-fractile-lagged.json.grib2

if [ $? -eq 0 ];then
  echo fractile/meps success on CPU!
else
  echo fractile/meps failed on CPU
  exit 1
fi

rm -f meps-fractile-lagged.json.grib2
