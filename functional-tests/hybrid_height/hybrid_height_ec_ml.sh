#!/bin/sh

set -x

#exit 0;

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f hybrid_height_ec_multilevel.json.grib

$HIMAN -d 5 -f hybrid_height_ec_multilevel.json -t grib source_ecmwf_euro_multilevel.grib

cnt=$(grib_count hybrid_height_ec_multilevel.json.grib)

if [ $cnt -eq 2 ];then
  echo hybrid_height/ec_ml success!
else
  echo hybrid_height/ec_ml failed
  exit 1
fi

rm -f hybrid_height_ec_multilevel.json.grib
