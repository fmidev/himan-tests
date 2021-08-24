#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f VV2*.grib

source_data=visibility_source_ec.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f ecmwf.json $source_data

grib_compare result_ec.grib ./VV2-M_height_0_rll_661_576_0_003.grib

if [ $? -eq 0 ];then
  echo visibility/ec success!
else
  echo visibility/ec failed
  exit 1
fi

rm -f VV2*.grib

