#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f blend-bias.grib2

$HIMAN -d 5 -f blend-bias.json source-blend-bias.grib2

grib_compare -r blend-bias.grib2 result-blend-bias.grib2

if [ $? -eq 0 ];then
  echo blend-bias success on CPU
else
  echo blend-bias failed on CPU
  exit 1
fi

rm -f blend-bias.grib2
