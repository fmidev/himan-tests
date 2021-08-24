#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f auto_taf.json.grib

../../bin/download-if-not-exists.sh autotaf_source_hir.grib

$HIMAN -d 5 -j 1 -f auto_taf.json --no-cuda autotaf_source_hir.grib

grib_compare auto_taf.json.grib result_hir.grib 

if [ $? -eq 0 ];then
  echo auto_taf/hirlam success on CPU!
else
  echo auto_taf/hirlam failed on CPU
  exit 1
fi

rm -f auto_taf.json.grib
