#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm turbulence_hir.json.grib

$HIMAN -d 5 -j 1 -f turbulence_hir.json -t grib --no-cuda source_hirlam.grib

grib_compare -A 1e-3 -R all=1e-3 turbulence_hir.json.grib result_hirlam.grib

if [ $? -eq 0 ];then
  echo turbulence/hirlam success on CPU!
else
  echo turbulence/hirlam failed on CPU
  exit 1
fi
rm turbulence_hir.json.grib

