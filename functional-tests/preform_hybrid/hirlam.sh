#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f PREC*grib

source_data=preform_hybrid_hirlam_source.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f hirlam-preform.json --no-cuda -s hirlam-stat $source_data

grib_compare hirlam-result.grib PRECFORM2-N_height_0_rll_1030_816_0_015.grib

if [ $? -ne 0 ];then
  echo preform_hybrid/hirlam failed on CPU
  exit 1
else
  echo preform_hybrid/hirlam success on CPU
fi

rm -f PREC*grib*
