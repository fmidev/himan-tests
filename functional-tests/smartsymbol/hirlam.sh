#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f WEATHER* SMARTSY* HESSAA* POT* PREC* FOG*

$HIMAN -d 4 -f hirlam.json hirlam_source.grib --no-cuda

grib_compare SMARTSYMBOL-N_height_0_rll_1030_816_0_001.grib hirlam_result_smartsymbol.grib

echo smartsymbol/hirlam success on CPU!

if [ ../../bin/check-for-gpu.sh ]; then
  rm -f WEATHER* SMARTSY* HESSAA*

  $HIMAN -d 4 -f hirlam.json hirlam_source.grib

  grib_compare SMARTSYMBOL-N_height_0_rll_1030_816_0_001.grib hirlam_result_smartsymbol.grib

  echo smartsymbol/hirlam success on GPU!
fi

rm -f WEATHER* SMARTSY* HESSAA* POT* PREC* FOG*

