#!/bin/sh

set -uxe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f T-C*.fqd

$HIMAN -d 5 -f ecmwf.json --no-cuda -s stat -t querydata ecmwf_source.grib

qddifference ecmwf_result.fqd ./T-C_ground_0_rll_161_177_0_001.fqd

if [ $? -eq 0 ];then
  echo querydata/ecmwf success!
else
  echo querydata/ecmwf failed
  exit 1
fi

rm -f T-C*.fqd
