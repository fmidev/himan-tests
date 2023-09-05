#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f DD-D*.grib FF-MS*.grib DF-MS*.grib

$HIMAN -d 5 -f windvector_hl_regular.json -t grib hl_regular_source.grib -s hl_reg_nocuda --no-cuda

grib_compare -A 0.01 hl_regular_result_FF.grib ./FF-MS_height_10_rll_1030_816_0_006.grib

if [ $? -eq 0 ];then
  echo windvector/hirlam regular grid wind speed success on CPU
else
  echo windvector/hirlam regular grid wind speed failed on CPU
  exit 1
fi

grib_compare -A 1 hl_regular_result_DD.grib ./DD-D_height_10_rll_1030_816_0_006.grib

if [ $? -eq 0 ];then
  echo windvector/hirlam regular grid wind direction success!
else
  echo windvector/hirlam regular grid wind direction failed
  exit 1
fi

if [ ../../bin/check-for-gpu.sh ]; then

  mv ./FF-MS_height_10_rll_1030_816_0_006.grib ./FF-MS_height_10_rll_1030_816_0_006-CPU.grib
  mv ./DD-D_height_10_rll_1030_816_0_006.grib ./DD-D_height_10_rll_1030_816_0_006-CPU.grib

  $HIMAN -d 5 -f windvector_hl_regular.json -t grib -s hl_reg_cuda hl_regular_source.grib

  grib_compare -b referenceValue -A 0.2 hl_regular_result_FF.grib ./FF-MS_height_10_rll_1030_816_0_006.grib

  if [ $? -eq 0 ];then
    echo windvector/hirlam regular grid wind speed success GPU
  else
    echo windvector/hirlam regular grid wind speed failed GPU
    exit 1
  fi

  grib_compare -A 1 hl_regular_result_DD.grib ./DD-D_height_10_rll_1030_816_0_006.grib

  if [ $? -eq 0 ];then
    echo windvector/hirlam regular grid wind direction success GPU
  else
    echo windvector/hirlam regular grid wind direction failed GPU
    exit 1
  fi
fi

echo "POLSTER NOT VERIFIED TO WORK YET"
rm -f DD-D*.grib FF-MS*.grib DF-MS*.grib

exit 0

$HIMAN -d 5 -f windvector_hl_staggered.json -t grib hl_staggered_source.grib --no-cuda -s hl_stag_nocuda

grib_compare -A 0.01 hl_staggered_result_FF.grib ./FF-MS_hybrid_55_polster_290_225_0_004.grib

if [ $? -eq 0 ];then
  echo windvector/hirlam staggered grid wind speed success!
else
  echo windvector/hirlam staggered grid wind speed failed
  exit 1
fi

grib_compare -A 0.01 hl_staggered_result_DD.grib ./DD-D_hybrid_55_polster_290_225_0_004.grib

if [ $? -eq 0 ];then
  echo windvector/hirlam staggered grid wind direction success!
else
  echo windvector/hirlam staggered grid wind direction failed
  exit 1
fi

if [ ../../bin/check-for-gpu.sh ]; then

  # Do the same test with cuda enabled; since the calculation cannot be made with cuda we must 
  # no the unpacking in cuda but calculation in cpu. results should be identical.

  $HIMAN -d 5 -f windvector_hl_staggered.json -t grib hl_staggered_source.grib -s hl_stag_cuda

  grib_compare -A 0.2 hl_staggered_result_FF.grib ./FF-MS_hybrid_55_polster_290_225_0_004.grib

  if [ $? -eq 0 ];then
    echo windvector/hirlam staggered grid wind speed success!
  else
    echo windvector/hirlam staggered grid wind speed failed
    exit 1
  fi

  grib_compare -A 1 hl_staggered_result_DD.grib ./DD-D_hybrid_55_polster_290_225_0_004.grib

  if [ $? -eq 0 ];then
    echo windvector/hirlam staggered grid wind direction success!
  else
    echo windvector/hirlam staggered grid wind direction failed
    exit 1
  fi
fi

