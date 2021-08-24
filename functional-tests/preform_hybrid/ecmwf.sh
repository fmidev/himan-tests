#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/release/himan"
fi

rm -f PRECFORM*.grib

source_data=preform_hybrid_ecmwf_source.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f preform_ec.json --no-cuda $source_data

grib_compare ./PRECFORM2-N_height_0_rll_661_576_0_003.grib ./ecmwf_result.grib

if [ $? -eq 0 ];then
  echo preform_hybrid/ecmwf success on CPU!
else
  echo preform_hybrid/ecmwf failed on CPU
  exit 1
fi

rm -f PREC*grib*
