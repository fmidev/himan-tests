#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f PREC*grib

source_data=preform_hybrid_harmonie_source.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f harmonie-preform.json --no-cuda -s harmonie-stat $source_data

grib_compare harmonie-result.grib PRECFORM2-N_height_0_rll_720_800_0_052.grib

if [ $? -ne 0 ];then
  echo preform_hybrid/harmonie failed on CPU
  exit 1
else
  echo preform_hybrid/harmonie success on CPU
fi

rm -f PREC*grib*
