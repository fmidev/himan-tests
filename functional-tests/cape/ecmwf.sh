#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f CAPE*.grib CIN*grib LFC*grib LCL*grib EL*grib

source_data=cape_ecmwf_mu_source.grib

../../bin/download-if-not-exists.sh $source_data

$HIMAN -s no-cuda -d 4 -f ecmwf.json --no-cuda $source_data

set -e 

grib_compare ./LCL-K_maxthetae_0_rll_661_576_0_003.grib result_LCL-K_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./LCL-HPA_maxthetae_0_rll_661_576_0_003.grib result_LCL-HPA_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./LFC-K_maxthetae_0_rll_661_576_0_003.grib result_LFC-K_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./LFC-HPA_maxthetae_0_rll_661_576_0_003.grib result_LFC-HPA_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./EL-K_maxthetae_0_rll_661_576_0_003.grib result_EL-K_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./EL-HPA_maxthetae_0_rll_661_576_0_003.grib result_EL-HPA_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./EL-LAST-K_maxthetae_0_rll_661_576_0_003.grib result_EL-LAST-K_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./EL-LAST-HPA_maxthetae_0_rll_661_576_0_003.grib result_EL-LAST-HPA_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./CAPE-JKG_maxthetae_0_rll_661_576_0_003.grib result_CAPE-JKG_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./CAPE1040-JKG_maxthetae_0_rll_661_576_0_003.grib result_CAPE1040-JKG_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./CAPE3KM-JKG_maxthetae_0_rll_661_576_0_003.grib result_CAPE3KM-JKG_maxthetae_0_rll_661_576_0_003.grib
grib_compare ./CIN-JKG_maxthetae_0_rll_661_576_0_003.grib result_CIN-JKG_maxthetae_0_rll_661_576_0_003.grib

echo cape/ecmwf success on CPU!

if [ $(echo $HIMAN | grep -c "debug") -gt 0 ]; then
  # cuda test is not run for debug builds
  rm -f CAPE*.grib CIN*grib LFC*grib LCL*grib EL*grib LPL*grib
  exit 0
fi

if [ $(/sbin/lsmod | egrep -c "^nvidia") -gt 0 ]; then

  rm -f CAPE*.grib CIN*grib LFC*grib LCL*grib EL*grib

  $HIMAN -s cuda -d 4 -f ecmwf.json $source_data

  grib_compare ./LCL-K_maxthetae_0_rll_661_576_0_003.grib result_gpu_LCL-K_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./LCL-HPA_maxthetae_0_rll_661_576_0_003.grib result_gpu_LCL-HPA_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./LFC-K_maxthetae_0_rll_661_576_0_003.grib result_gpu_LFC-K_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./LFC-HPA_maxthetae_0_rll_661_576_0_003.grib result_gpu_LFC-HPA_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./EL-K_maxthetae_0_rll_661_576_0_003.grib result_gpu_EL-K_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./EL-HPA_maxthetae_0_rll_661_576_0_003.grib result_gpu_EL-HPA_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./EL-LAST-K_maxthetae_0_rll_661_576_0_003.grib result_gpu_EL-LAST-K_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./EL-LAST-HPA_maxthetae_0_rll_661_576_0_003.grib result_gpu_EL-LAST-HPA_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./CAPE-JKG_maxthetae_0_rll_661_576_0_003.grib result_gpu_CAPE-JKG_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./CAPE1040-JKG_maxthetae_0_rll_661_576_0_003.grib result_gpu_CAPE1040-JKG_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./CAPE3KM-JKG_maxthetae_0_rll_661_576_0_003.grib result_gpu_CAPE3KM-JKG_maxthetae_0_rll_661_576_0_003.grib
  grib_compare ./CIN-JKG_maxthetae_0_rll_661_576_0_003.grib result_gpu_CIN-JKG_maxthetae_0_rll_661_576_0_003.grib

  echo cape/ecmwf success on GPU!
else
  echo "no cuda device found for cuda tests"
fi
rm -f CAPE*.grib CIN*grib LFC*grib LCL*grib EL*grib LPL*grib

