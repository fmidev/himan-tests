#!/bin/sh

set -x
if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f RRR*-KGM2_height_0_ll_1440_721_0_041.grib PRECFORM3-N_height_0_ll_1440_721_0_041.grib

$HIMAN -d 4 -f gfs_prec.json gfs_prec_source.grib -s stat --no-cuda

#grib_compare RRR-KGM2_height_0_ll_1440_721_0_041.grib gfs_rrr_result.grib

#if [ $? -ne 0 ];then
#  echo luatool/gfs failed on CPU
#  exit 1
#fi

#grib_compare RRRC-KGM2_height_0_ll_1440_721_0_041.grib gfs_rrrc_result.grib

#if [ $? -ne 0 ];then
#  echo luatool/gfs failed on CPU
#  exit 1
#fi

grib_compare PRECFORM3-N_height_0_ll_1440_721_0_041.grib gfs_precform_result.grib

if [ $? -ne 0 ];then
  echo luatool/gfs failed on CPU
  exit 1
fi

echo luatool/gfs success on CPU

rm -f RRR*-KGM2_height_0_ll_1440_721_0_041.grib PRECFORM3-N_height_0_ll_1440_721_0_041.grib

