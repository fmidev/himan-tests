#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f PREC*grib*

source_data=preform_hybrid_meps_source.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f meps-preform.json --no-cuda -s meps-stat $source_data -t grib2

grib_compare meps-result.grib PRECFORM2-N_height_0_lcc_889_949_0_003_4_0.grib2

if [ $? -ne 0 ];then
  echo preform_hybrid/meps failed on CPU
  exit 1
else
  echo preform_hybrid/meps success on CPU
fi

rm -f PREC*grib*

