#!/bin/sh

set -uxe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f extra-options.json.grib2

$HIMAN -d 5 -f extra-options.json --no-cuda -t grib2 bbox.grib

shape=$(grib_get -p shapeOfTheEarth extra-options.json.grib2)
lat=$(grib_get -p latitudeOfFirstGridPointInDegrees extra-options.json.grib2)

if [ $shape -eq 6 ] && [ "$lat" = "-65.03" ];then
  echo extra-options success!
else
  echo extra-options failed
  exit 1
fi

rm -f extra-options.json.grib2
