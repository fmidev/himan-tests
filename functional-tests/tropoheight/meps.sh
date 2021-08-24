#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f tropopause_meps.json.grib*

../../bin/download-if-not-exists.sh tropoheight_source_meps.grib
 
$HIMAN -d 5 -f tropopause_meps.json -t grib --no-cuda tropoheight_source_meps.grib

grib_compare tropopause_meps.json.grib result_meps.grib

if [ $? -eq 0 ];then
  echo tropopause/meps success on CPU!
else
  echo tropopause/meps failed on CPU
  exit 1
fi

rm -f tropopause_meps.json.grib*
