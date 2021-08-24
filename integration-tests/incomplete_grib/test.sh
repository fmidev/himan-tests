#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

cp test_incomplete.grib.orig test_incomplete.grib

$HIMAN -d 4 -f test.json source.grib2

cnt=$(grib_count test_incomplete.grib)

if [ $cnt -ne 2 ]; then
  echo "failed"
  exit 1
fi

echo "incomplete_grib success"

rm -f test_incomplete.grib
