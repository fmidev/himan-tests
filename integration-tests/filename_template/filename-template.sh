#!/bin/sh

set -xue

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

$HIMAN -d 4 -f filename-template.json -t grib filename-template-source.grib

cnt=$(grib_count test_243_2020_04_28_00_2020_04_28_06_step06_ECEUR0200_rll_331x289_P-PA_unknown_not_a_date_time_unknown_-999.-999_height_2.-999_cf_00000.grib)

if [ $cnt -ne 1 ]; then
  echo "filename_template failed"
  exit 1
fi

$HIMAN -d 4 -f filename-template.json -t querydata filename-template-source.grib

val=$(qdpoint -x 25 -y 60 test_243_2020_04_28_00_2020_04_28_06_step06_ECEUR0200_rll_331x289_P-PA_unknown_not_a_date_time_unknown_-999.-999_height_2.-999_cf_00000.fqd)

if [ "$val" != "202004280900 100762" ]; then
  echo "filename_template failed"
  exit 1
fi

cnt=$(grib_count test_2020/04_28.grib)

if [ ! -f "test_2020/04_28.grib" ] || [ $cnt -ne 1 ]; then
  echo "filename_template failed"
  exit 1
fi

date=$(date +%Y-%m-%d)

if [ ! -f "test_$date.grib" ]; then
  echo "filename_template failed"
  exit 1
fi

if [ ! -f "test_2020:04:28:006.grib" ]; then
  echo "filename_template failed"
  exit 1
fi

echo "filename_template success"

rm -rf test_2020
rm -f test_*{grib,fqd} test_$date.grib
