#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f tropopause_hirlam.json.grib

../../bin/download-if-not-exists.sh tropoheight_source_hirlam.grib
 
$HIMAN -d 5 -f tropopause_hirlam.json -t grib --no-cuda tropoheight_source_hirlam.grib

grib_compare tropopause_hirlam.json.grib result_hirlam.grib

if [ $? -eq 0 ];then
  echo tropopause/hirlam success on CPU!
else
  echo tropopause/hirlam failed on CPU
  exit 1
fi

rm -f tropopause_hirlam.json.grib
