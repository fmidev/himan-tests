#!/bin/sh
exit 0 # disabled for now; source data does not cover 4 grid points
       # and hitool fetches the whole vertical data from 137 to 24
set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f icing_ec.json.grib

../../bin/download-if-not-exists.sh icing-ecmwf-source.grib

$HIMAN -d 5 -j 1 -f icing_ec.json -t grib icing-ecmwf-source.grib  --no-cuda

grib_compare result_ec.grib icing_ec.json.grib

if [ $? -eq 0 ];then
  echo icing/ec success!
else
  echo icing/ec failed
  exit 1
fi

