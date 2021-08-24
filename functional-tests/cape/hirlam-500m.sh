#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f CAPE*.grib CIN*grib LFC*grib LCL*grib EL*grib

source_data=cape_hirlam_500m_source.grib

if [ ! -f "$source_data" ]; then
  echo "source data not present, copying it"
  curl https://lake.fmi.fi/himan-tests-source-data/$source_data -o $source_data

  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

$HIMAN -s no-cuda -d 4 -f hirlam-500m.json --no-cuda $source_data

set -e

grib_compare -A 0.2 ./LCL-K_height_layer_500-0_rll_1030_816_0_024.grib result_LCL-K_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 1 ./LCL-HPA_height_layer_500-0_rll_1030_816_0_024.grib result_LCL-HPA_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 0.2 ./LFC-K_height_layer_500-0_rll_1030_816_0_024.grib result_LFC-K_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 1 ./LFC-HPA_height_layer_500-0_rll_1030_816_0_024.grib result_LFC-HPA_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 0.2 ./EL-K_height_layer_500-0_rll_1030_816_0_024.grib result_EL-K_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 1 ./EL-HPA_height_layer_500-0_rll_1030_816_0_024.grib result_EL-HPA_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 0.2 ./EL-LAST-K_height_layer_500-0_rll_1030_816_0_024.grib result_EL-LAST-K_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 1 ./EL-LAST-HPA_height_layer_500-0_rll_1030_816_0_024.grib result_EL-LAST-HPA_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 1 ./CAPE-JKG_height_layer_500-0_rll_1030_816_0_024.grib result_CAPE-JKG_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 1 ./CAPE1040-JKG_height_layer_500-0_rll_1030_816_0_024.grib result_CAPE1040-JKG_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 1 ./CAPE3KM-JKG_height_layer_500-0_rll_1030_816_0_024.grib result_CAPE3KM-JKG_height_layer_500-0_rll_1030_816_0_024.grib
grib_compare -A 1 ./CIN-JKG_height_layer_500-0_rll_1030_816_0_024.grib result_CIN-JKG_height_layer_500-0_rll_1030_816_0_024.grib

echo cape/hirlam success on CPU!

if [ $(echo $HIMAN | grep -c "debug") -gt 0 ]; then
  # cuda test is not run for debug builds
  rm -f CAPE*.grib CIN*grib LFC*grib LCL*grib EL*grib
  exit 0
fi

if [ $(/sbin/lsmod | egrep -c "^nvidia") -gt 0 ]; then

  rm -f CAPE*.grib CIN*grib LFC*grib LCL*grib EL*grib

  $HIMAN -s cuda -d 4 -f hirlam-500m.json $source_data

  grib_compare -A 0.2 ./LCL-K_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_LCL-K_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 1 ./LCL-HPA_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_LCL-HPA_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 0.2 ./LFC-K_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_LFC-K_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 1 ./LFC-HPA_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_LFC-HPA_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 0.2 ./EL-K_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_EL-K_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 1 ./EL-HPA_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_EL-HPA_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 0.2 ./EL-LAST-K_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_EL-LAST-K_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 1 ./EL-LAST-HPA_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_EL-LAST-HPA_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 1 ./CAPE-JKG_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_CAPE-JKG_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 1 ./CAPE1040-JKG_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_CAPE1040-JKG_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 1 ./CAPE3KM-JKG_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_CAPE3KM-JKG_height_layer_500-0_rll_1030_816_0_024.grib
  grib_compare -A 1 ./CIN-JKG_height_layer_500-0_rll_1030_816_0_024.grib result_gpu_CIN-JKG_height_layer_500-0_rll_1030_816_0_024.grib

  echo cape/hirlam success on GPU!
else
  echo "no cuda device found for cuda tests"
fi
rm -f CAPE*.grib CIN*grib LFC*grib LCL*grib EL*grib

