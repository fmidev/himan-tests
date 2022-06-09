#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f rm CLDTYPE-N* NWCSAF_EFFCLD-0TO1*

$HIMAN -d 5 -f nwcsaf.json -t geotiff ct.tif ctth_quality.tif ctth_effectiv.tif --no-cuda

export PATH=$PATH:/usr/gdal34/bin

mean=$(gdalinfo -stats CLDTYPE-N_height_0_lcc_606_682_0_000.tif | grep MEAN | cut -d '=' -f 2 | head -c 10)

test $mean = 1.67218240

# mean=$(gdalinfo -stats NWCSAF_EFFCLD-0TO1_height_0_lcc_606_682_0_000.tif | grep MEAN | cut -d '=' -f 2 | head -c 10)

# test $mean = 0.64361442

if [ $? -eq 0 ];then
  echo nwcsaf success on CPU!
else
  echo nwcsaf failed on CPU
  exit 1
fi

rm -f rm CLDTYPE-N* NWCSAF_EFFCLD-0TO1*

