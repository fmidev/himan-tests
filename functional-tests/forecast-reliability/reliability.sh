#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
        export HIMAN="../../himan-bin/build/debug/himan"
fi

# Remove any old files created by the test 
rm -f fc*grib

# Download from cloud if local source does not exist
../../bin/download-if-not-exists.sh source-mepsmta.grib

# Run himan and compare results
$HIMAN -d 5 -f reliability-mepsmta.json -t grib --no-cuda source-mepsmta.grib | tee out

grib_compare -A 0.001 fc202609160000+000h00m.grib result-mepsmta.grib
if [ $? -eq 0 ];then
  echo MEPSMTA reliability success on CPU!
else
  echo MEPSMTA reliability failed on CPU
  exit 1
fi

# Remove any old files created by the test 
rm -f fc*grib
