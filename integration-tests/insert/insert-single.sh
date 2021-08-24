#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

. $PWD/initsh

stub=109/201911291800/LAPSLAMBERT2500/0/
export MASALA_PROCESSED_DATA_BASE=$PWD

rm -rf 109

$HIMAN -d 4 -f insert-single.json -t grib2 insert-source.grib2

cnt=$(ls -1 $stub/*pressure*.grib2 | wc -l)

if [ $cnt -ne 4 ]; then
  echo "failed"
  exit 1
fi

cnt=$(ls -1 $stub/*height*.grib2 | wc -l)

if [ $cnt -ne 2 ]; then
  echo "failed"
  exit 1
fi

. $PWD/check-dbsh

echo "insert/single success"

rm -rf 109
