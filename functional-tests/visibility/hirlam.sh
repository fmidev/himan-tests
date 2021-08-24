#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f VV2*.grib

source_data=visibility_source_hirlam.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f hirlam.json $source_data

grib_compare result_hirlam.grib ./VV2-M_height_0_rll_1030_816_0_047.grib

if [ $? -eq 0 ];then
  echo visibility/hirlam success!
else
  echo visibility/hirlam failed
  exit 1
fi

rm -f VV2*.grib

