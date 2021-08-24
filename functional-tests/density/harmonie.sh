#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f RHO-KGM3*.grib

$HIMAN -d 5 -f density_harmonie.json -t grib --no-cuda harmonie_p_source.grib harmonie_t_source.grib

grib_compare -A 0.1 ./RHO-KGM3_hybrid_65_rll_290_594_0_006.grib result_harmonie.grib 

if [ $? -eq 0 ];then
  echo density/harmonie success on CPU!
else
  echo density/harmonie failed on CPU
  exit 1
fi

rm -f RHO-KGM3*.grib
