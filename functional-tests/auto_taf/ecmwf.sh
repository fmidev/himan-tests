#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f auto_taf_ec.json.grib

../../bin/download-if-not-exists.sh autotaf_source_ec.grib

$HIMAN -d 5 -j 1 -f auto_taf_ec.json --no-cuda autotaf_source_ec.grib

grib_compare auto_taf_ec.json.grib result_ec.grib 

if [ $? -eq 0 ];then
  echo auto_taf/ecmwf succes on CPU!
else
  echo auto_taf/ecmwf failed on CPU
  exit 1
fi

rm -f auto_taf_ec.json.grib
