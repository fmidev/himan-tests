#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f fc202205300000+024h00m.grib 

$HIMAN -d 5 -j 1 -f ecmwf.json -t grib --no-cuda source.grib

grib_compare fc202205300000+024h00m.grib result.grib

if [ $? -eq 0 ];then
  echo rajuilma/ecmwf success on CPU!
else
  echo rajuilma/ecmwf failed on CPU
  exit 1
fi
