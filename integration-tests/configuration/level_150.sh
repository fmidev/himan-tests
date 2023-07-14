#!/bin/sh

set -uxe

rm -f level_150.json.grib

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

$HIMAN -d 5 -f level_150.json --no-cuda bbox.grib 

if [ $? -ne 0 ]; then
  echo level_150 failed
  exit 1
fi

test 6 -eq $(grib_get -p NV level_150.json.grib)
test 150 -eq $(grib_get -p typeOfFirstFixedSurface level_150.json.grib)
test 74 -eq $(grib_get -p scaledValueOfFirstFixedSurface level_150.json.grib)
test 150 -eq $(grib_get -p typeOfSecondFixedSurface level_150.json.grib)
test 75 -eq $(grib_get -p scaledValueOfSecondFixedSurface level_150.json.grib)
test 75 -eq $(grib_get -p nlev level_150.json.grib)
test 4 -eq $(grib_get -p numberOfVGridUsed level_150.json.grib)

rm -f level_150.json.grib
