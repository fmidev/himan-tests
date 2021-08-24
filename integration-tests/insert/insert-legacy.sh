#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

. $(dirname $0)/initsh

rm -rf 109 insert-legacy-*.json.grib*

$HIMAN -d 4 -f insert-legacy-1.json -t grib2 insert-source.grib2

cnt=$(ls -1 109/201911291800/LAPSLAMBERT2500/0/ | wc -l)

if [ $cnt -ne 6 ]; then
  echo "failed"
  exit 1
fi

. $PWD/check-dbsh

echo "insert/legacy-1 success"

rm -rf 109 insert-legacy-*.json.grib*

$HIMAN -d 4 -f $PWD/insert-legacy-2.json -t grib2 insert-source.grib2

cnt=$(grib_count ./insert-legacy-2.json.grib2)

if [ $cnt -ne 6 ]; then
  echo "failed"
  exit 1
fi

echo "insert/legacy-2 success"

rm -f ./insert-legacy-*.json.grib*
