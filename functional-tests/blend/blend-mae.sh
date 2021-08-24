#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f blend-mae.grib2

$HIMAN -d 5 -f blend-mae.json source-blend-mae.grib2

grib_compare blend-mae.grib2 result-blend-mae.grib2

if [ $? -eq 0 ];then
  echo blend-mae success on CPU
else
  echo blend-mae failed on CPU
  exit 1
fi

rm -f blend-mae.grib2
