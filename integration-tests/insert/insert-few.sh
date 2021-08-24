#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

. $PWD/initsh
stub=109/201911291800/LAPSLAMBERT2500/

rm -rf 109

$HIMAN -d 4 -f insert-few.json -t grib2 insert-source.grib2

cnt=$(grib_count $stub/fc201911291800+000h00m_windvector#0.grib2)

if [ $cnt -ne 4 ]; then
  echo "failed"
  exit 1
fi

cnt=$(grib_count $stub/fc201911291800+000h00m_windvector#1.grib2)

if [ $cnt -ne 2 ]; then
  echo "failed"
  exit 1
fi

. $PWD/check-dbsh

echo "insert/few success"

rm -rf 109
