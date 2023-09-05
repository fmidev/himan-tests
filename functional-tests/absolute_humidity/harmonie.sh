#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f RHO-KGM3*.grib ABS*.grib

$HIMAN -d 4 -f absolute_humidity_harmonie.json -t grib harmonie_p_source.grib harmonie_t_source.grib harmonie_rain_source.grib harmonie_snow_source.grib harmonie_graupel_source.grib --no-cuda

grib_compare ./ABSH-KGM3_hybrid_60_rll_290_594_0_006.grib harmonie_result.grib
VAR_1=$?

if [ $VAR_1 -eq 0 ];then
  echo absolute_humidity/harmonie success on CPU!
else
  echo absolute_humidity/harmonie failed on CPU
  exit 1
fi

if [ ../../bin/check-for-gpu.sh ]; then
  rm -f RHO-KGM3*.grib ABS*.grib

  $HIMAN -d 5 -f absolute_humidity_harmonie.json -t grib harmonie_p_source.grib harmonie_t_source.grib harmonie_rain_source.grib harmonie_snow_source.grib harmonie_graupel_source.grib

  grib_compare -A 0.1 ./ABSH-KGM3_hybrid_60_rll_290_594_0_006.grib harmonie_result.grib
  VAR_1=$?

  if [ $VAR_1 -eq 0 ];then
    echo absolute_humidity/harmonie success on GPU!
  else
    echo absolute_humidity/harmonie failed on GPU
    exit 1
  fi

fi
rm -f RHO-KGM3*.grib RRR*.grib ABS*grib
