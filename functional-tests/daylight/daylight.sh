#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
        export HIMAN="../../himan-bin/build/debug/himan"
fi

# Remove any old files created by the test 
rm -f fc*grib

# Does not need source data

# Run himan and compare results
$HIMAN -d 5 -f daylight-mepsmta.json -t grib --no-cuda | tee out

grib_compare -A 0.001 fc202609160000+000h00m.grib result-mepsmta.grib
if [ $? -eq 0 ];then
  echo MEPSMTA daylight index success on CPU!
else
  echo MEPSMTA daylight index failed on CPU
  exit 1
fi

# Remove any old files created by the test 
rm -f fc*grib
