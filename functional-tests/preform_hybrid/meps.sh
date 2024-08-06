#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f PRECFORM2*lcc*grib2

source_data=preform_hybrid_meps_source.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f meps-preform.json --no-cuda -s meps-stat $source_data -t grib2

grib_compare PRECFORM2-N_height_0_lcc_949_1069_0_003_4_0.grib2 meps-result.grib

if [ $? -ne 0 ];then
  echo preform_hybrid/meps failed on CPU
  exit 1
else
  echo preform_hybrid/meps success on CPU
fi

rm -f PRECFORM2*lcc*grib2 meps-preform-summer.grib2

source_data=preform_hybrid_meps_source2.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f meps-preform-summer.json --no-cuda -s meps-stat $source_data -t grib2

grib_compare meps-preform-summer.grib2 meps-summer-result.grib

if [ $? -ne 0 ];then
  echo preform_hybrid/meps-summer failed on CPU
  exit 1
else
  echo preform_hybrid/meps-sumer success on CPU
fi

rm -f meps-preform-summer.grib2

