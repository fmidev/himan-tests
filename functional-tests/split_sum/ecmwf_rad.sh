#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f RTOP*grib RADGLO*grib

$HIMAN -d 5 -f radiation_ec.json -t grib ec_radiation_source.grib --no-cuda -s ec_nocuda

grib_compare ec_radiation_result.grib ./RTOPLW-WM2_height_0_rll_161_177_0_089.grib

if [ $? -ne 0 ];then
  echo radiation/ecmwf failed on CPU
  exit 1
fi

$HIMAN -f radiation_ec_globc.json ec_source_radgloc.grib

grib_compare ec_result_radgloc.grib ./RADGLOC-WM2_height_0_ll_3600_1801_0_010.grib

if [ $? -ne 0 ];then
  echo radiation/ecmwf failed on CPU
  exit 1
fi

echo radiation/ecmwf success on CPU
rm -f RTOP*grib RADGLO*grib

