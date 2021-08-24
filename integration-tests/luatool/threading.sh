#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f ./T-K_height_0_rll_1030_816_0_*grib

$HIMAN -d 4 -f threading.json threading_source.grib --no-cuda

for i in $(seq 37 41); do
  grib_compare ./T-K_height_0_rll_1030_816_0_0$i.grib threading_result_$i.grib
done

echo luatool/hirlam success on CPU!

rm -f ./T-K_height_0_rll_1030_816_0_*grib

