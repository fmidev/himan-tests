#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f source-forecast-period.json.grib2

$HIMAN -d 4 -f source-forecast-period.json -t grib2 --no-cuda gfs_source.grib2

grib_compare source-forecast-period.json.grib2 source-forecast-period-result.grib2

if [ $? -eq 0 ];then
  echo transformer/source-forecast-period success!
else
  echo transformer/source-forecast-period failed
  exit 1
fi

rm -f source-forecast-period.json.grib2
