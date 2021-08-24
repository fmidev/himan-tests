#!/bin/sh

set -ux

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

sed -e '/ALLOWED/d' allowed_missing.json > test.json
$HIMAN -d 5 -f test.json --no-cuda bbox.grib -s

if [ $? -ne 0 ];then
  echo allowed_missing failed
  exit 1
fi

sed -e 's/ALLOWED/100/g' allowed_missing.json > test.json
$HIMAN -d 5 -f test.json --no-cuda bbox.grib -s

if [ $? -ne 1 ];then
  echo allowed_missing failed
  exit 1
fi

sed -e 's/ALLOWED/90%/g' allowed_missing.json > test.json
$HIMAN -d 5 -f test.json --no-cuda bbox.grib -s

if [ $? -eq 0 ];then
  echo allowed_missing success!
else
  echo allowed_missing failed
  exit 1
fi

rm -f test.*
