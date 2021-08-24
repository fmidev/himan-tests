#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

$HIMAN -d 4 -f filename-template.json -t grib filename-template-source.grib

cnt=$(grib_count test_230_2020_03_24_00_2020_03_24_01_step01_RCR068_rll_1030x816_T-C_unknown_not_a_date_time_unknown_-999.-999_height_2.-999_det_-0999.grib)

if [ $cnt -ne 1 ]; then
  echo "filename_template failed"
  exit 1
fi

$HIMAN -d 4 -f filename-template.json -t querydata filename-template-source.grib

val=$(qdpoint -x 25 -y 60 test_230_2020_03_24_00_2020_03_24_01_step01_RCR068_rll_1030x816_T-C_unknown_not_a_date_time_unknown_-999.-999_height_2.-999_det_-0999.fqd)

if [ "$val" != "202003240300 2.1" ]; then
  echo "filename_template failed"
  exit 1
fi

$HIMAN -d 4 -f filename-template2.json -t grib filename-template-source.grib

cnt=$(grib_count 2020/03_24.grib)

if [ ! -f "2020/03_24.grib" ] || [ $cnt -ne 1 ]; then
  echo "filename_template failed"
  exit 1
fi

echo "filename_template success"

rm -rf 2020
rm -f test_230*{grib,fqd}
