#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f auto_taf_meps.json.grib

../../bin/download-if-not-exists.sh autotaf_source_meps.grib

$HIMAN -d 5 -j 1 -f auto_taf_meps.json --no-cuda autotaf_source_meps.grib

grib_compare auto_taf_meps.json.grib result_meps.grib 

if [ $? -eq 0 ];then
  echo auto_taf/meps success on CPU!
else
  echo auto_taf/meps failed on CPU
  exit 1
fi

rm -f auto_taf_meps.json.grib
