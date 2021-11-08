#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

. $PWD/initsh

export MASALA_PROCESSED_DATA_BASE=$PWD

rm -rf 109

$HIMAN -j 1 -d 4 -f insert-ss_state.json -t grib2 insert-source.grib2

cnt=$(echo "SELECT count(*) FROM ss_state_v WHERE table_name = 'xxxxxx'" | psql -Aqt)

if [ $cnt -eq 1 ]; then
  echo "insert/ss_state success"
else
  echo "insert/ss_state failed"
  exit 1
fi

rm -rf 109
