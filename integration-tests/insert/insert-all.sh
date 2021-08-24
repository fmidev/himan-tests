#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

. $PWD/initsh

rm -rf 109

$HIMAN -d 4 -f insert-all.json -t grib2 insert-source.grib2

cnt=$(grib_count 109/201911291800/LAPSLAMBERT2500/fc201911291800+000h00m.grib2)

if [ $cnt -ne 6 ]; then
  echo "failed"
  exit 1
fi

. $PWD/check-dbsh

echo "insert/all success"

rm -rf 109
