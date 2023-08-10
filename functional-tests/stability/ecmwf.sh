#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

ls | egrep "^[A-Z].*rll_661*" | xargs -d"\n" rm -f

../../bin/download-if-not-exists.sh stability-ec-full-source.grib

$HIMAN -d 4 -f stability-ec-full.json stability-ec-full-source.grib --no-cuda -s

grib_compare -b referenceValue -A 0.1 CSI-N_height_0_rll_661_576_0_012.grib result_CSI-N_height_0_rll_661_576_0_012.grib
grib_compare -A 0.1 EWSH-MS_maxwind_0_rll_661_576_0_012.grib result_EWSH-MS_max_wind_0_rll_661_576_0_012.grib
grib_compare -A 0.1 LI-N_height_0_rll_661_576_0_012.grib result_LI-N_height_0_rll_661_576_0_012.grib
grib_compare -A 0.1 SI-N_height_0_rll_661_576_0_012.grib result_SI-N_height_0_rll_661_576_0_012.grib
grib_compare -A 0.1 WSH-MS_height_layer_1000-0_rll_661_576_0_012.grib2 result_WSH-MS_height_layer_1000-0_rll_661_576_0_012.grib
grib_compare -A 0.1 HLCY-M2S2_height_layer_1000-0_rll_661_576_0_012.grib2 result_HLCY-M2S2_height_layer_1000-0_rll_661_576_0_012.grib
grib_compare -A 0.1 EHI-N_height_layer_1000-0_rll_661_576_0_012.grib2 result_EHI-N_height_layer_1000-0_rll_661_576_0_012.grib
grib_compare -A 0.1 WSH-MS_height_layer_3000-0_rll_661_576_0_012.grib2 result_WSH-MS_height_layer_3000-0_rll_661_576_0_012.grib
grib_compare -A 0.1 HLCY-M2S2_height_layer_3000-0_rll_661_576_0_012.grib2 result_HLCY-M2S2_height_layer_3000-0_rll_661_576_0_012.grib
grib_compare -A 0.1 TPE-K_height_layer_3000-0_rll_661_576_0_012.grib2 result_TPE-K_height_layer_3000-0_rll_661_576_0_012.grib
grib_compare -A 0.1 WSH-MS_height_layer_6000-0_rll_661_576_0_012.grib2 result_WSH-MS_height_layer_6000-0_rll_661_576_0_012.grib
grib_compare -A 0.1 BRN-N_height_layer_6000-0_rll_661_576_0_012.grib2 result_BRN-N_height_layer_6000-0_rll_661_576_0_012.grib
grib_compare -A 0.1 FF-MS_height_1500_rll_661_576_0_012.grib result_FF-MS_height_1500_rll_661_576_0_012.grib

echo stability/ec success on CPU

if [ $(/sbin/lsmod | egrep -c "^nvidia") -gt 0 ]; then

  ls | egrep "^[A-Z].*rll_661*" | xargs -d"\n" rm -f

  $HIMAN -d 4 -f stability-ec-full.json stability-ec-full-source.grib -s

  grib_compare -b referenceValue -A 0.1 CSI-N_height_0_rll_661_576_0_012.grib result_CSI-N_height_0_rll_661_576_0_012.grib
  grib_compare -A 0.1 EWSH-MS_maxwind_0_rll_661_576_0_012.grib result_EWSH-MS_max_wind_0_rll_661_576_0_012.grib
  grib_compare -A 0.1 LI-N_height_0_rll_661_576_0_012.grib result_LI-N_height_0_rll_661_576_0_012.grib
  grib_compare -A 0.1 SI-N_height_0_rll_661_576_0_012.grib result_SI-N_height_0_rll_661_576_0_012.grib
  grib_compare -A 0.1 WSH-MS_height_layer_1000-0_rll_661_576_0_012.grib2 result_WSH-MS_height_layer_1000-0_rll_661_576_0_012.grib
  grib_compare -A 0.1 HLCY-M2S2_height_layer_1000-0_rll_661_576_0_012.grib2 result_HLCY-M2S2_height_layer_1000-0_rll_661_576_0_012.grib
  grib_compare -A 0.1 EHI-N_height_layer_1000-0_rll_661_576_0_012.grib2 result_EHI-N_height_layer_1000-0_rll_661_576_0_012.grib
  grib_compare -A 0.1 WSH-MS_height_layer_3000-0_rll_661_576_0_012.grib2 result_WSH-MS_height_layer_3000-0_rll_661_576_0_012.grib
  grib_compare -A 0.1 HLCY-M2S2_height_layer_3000-0_rll_661_576_0_012.grib2 result_HLCY-M2S2_height_layer_3000-0_rll_661_576_0_012.grib
  grib_compare -A 0.1 TPE-K_height_layer_3000-0_rll_661_576_0_012.grib2 result_TPE-K_height_layer_3000-0_rll_661_576_0_012.grib
  grib_compare -A 0.1 WSH-MS_height_layer_6000-0_rll_661_576_0_012.grib2 result_WSH-MS_height_layer_6000-0_rll_661_576_0_012.grib
  grib_compare -A 0.1 BRN-N_height_layer_6000-0_rll_661_576_0_012.grib2 result_BRN-N_height_layer_6000-0_rll_661_576_0_012.grib
  grib_compare -A 0.1 FF-MS_height_1500_rll_661_576_0_012.grib result_FF-MS_height_1500_rll_661_576_0_012.grib

  echo stability/ec success on GPU!
else
  echo "no cuda device found for cuda tests"
fi

ls | egrep "^[A-Z].*rll_661*" | xargs -d"\n" rm -f

