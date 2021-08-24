#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f T-K*.grib2

$HIMAN -d 5 -f blend-blend.json source-blend-blend.grib2

grib_compare T-K_height_2_lcc_869_929_0_012.grib2 result-blend-blend.grib2

if [ $? -eq 0 ];then
  echo blend-blend success on CPU
else
  echo blend-blend failed on CPU
  exit 1
fi

rm -f T-K*.grib2
