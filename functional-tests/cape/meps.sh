#!/bin/sh

set -ex

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f CAPE*.grib2 CIN*.grib2 LFC*.grib2 LCL*.grib2 EL*.grib2

source_data=cape_meps_mu_source.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -s no-cuda -d 3 -f meps.json --no-cuda $source_data -t grib2 

set -e

grib_compare ./LCL-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_LCL-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./LCL-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_LCL-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./LFC-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_LFC-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./LFC-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_LFC-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./EL-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_EL-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./EL-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_EL-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./EL-LAST-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_EL-LAST-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./EL-LAST-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_EL-LAST-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./CAPE-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_CAPE-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./CAPE1040-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_CAPE1040-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./CAPE3KM-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_CAPE3KM-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2
grib_compare ./CIN-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_CIN-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2

echo cape/meps success on CPU!

if [ $(echo $HIMAN | grep -c "debug") -gt 0 ]; then
  # cuda test is not run for debug builds
  rm -f CAPE*.grib2 CIN*.grib2 LFC*.grib2 LCL*.grib2 EL*.grib2 LPL*grib2
  exit 0
fi

if [ ../../bin/check-for-gpu.sh ]; then

  rm -f CAPE*_4_0.grib2 CIN_4_0.grib2 LFC_4_0.grib2 LCL_4_0.grib2 EL_4_0.grib2

  $HIMAN -s cuda -d 3 -f meps.json $source_data -t grib2 

  grib_compare ./LCL-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_LCL-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare ./LCL-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_LCL-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare ./LFC-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_LFC-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare ./LFC-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_LFC-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare -A 0.2 ./EL-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_EL-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare -A 1 ./EL-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_EL-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare -A 0.2 ./EL-LAST-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_EL-LAST-K_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare -A 1 ./EL-LAST-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_EL-LAST-HPA_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare ./CAPE-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_CAPE-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare -A 1 ./CAPE1040-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_CAPE1040-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare -A 1 ./CAPE3KM-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_CAPE3KM-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2
  grib_compare -A 1 ./CIN-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2 result_gpu_CIN-JKG_maxthetae_0_lcc_889_949_0_003_4_0.grib2

  echo cape/meps success on GPU!
else
  echo "no cuda device found for cuda tests"
fi

rm -f CAPE*.grib2 CIN*.grib2 LFC*.grib2 LCL*.grib2 EL*.grib2 LPL*grib2

