#!/bin/sh
set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f *m.grib

source_data=ceiling_fractile_meps_source.grib
../../bin/download-if-not-exists.sh $source_data

$HIMAN -d 4 -f meps.json $source_data -s stat --no-cuda

grib_compare fc202501070600+006h00m.grib2 result_meps.grib2

if [ $? -ne 0 ];then
  echo ceiling fractile/meps failed on CPU
  exit 1
fi

echo ceiling fractile/meps success on CPU
rm -f *m.grib2
rm -f ceiling_fractile_meps_source.grib
