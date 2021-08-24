#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f F*T-K*.grib2 T-MEAN*grib2 T-STDDEV*grib2

$HIMAN -s no-cuda -d 4 -f ecmwf.json ecmwf_source.grib --no-cuda

grib_compare ecmwf_result.grib F25-T-K_height_2_rll_331_289_0_006_5.grib2

if [ $? -eq 0 ];then
  echo fractile/ecmwf success on CPU!
else
  echo fractile/ecmwf failed on CPU
  exit 1
fi

rm -f F*T-K*.grib2 T-MEAN*grib2 T-STDDEV*grib2
