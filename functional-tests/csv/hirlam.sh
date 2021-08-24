#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f T-C_*.csv T-K*.csv

$HIMAN -d 5 -f hirlam.json -t csv --no-cuda -s hirlam hirlam_source.grib

lc=`cat T-C_pressure_850_pointlist_0_001.csv | wc -l`

if [ $lc -ne 3 ]; then
  echo "csv failed"
  exit 1
fi

temp=$(grep 25 T-C_pressure_850_pointlist_0_001.csv | cut -d "," -f 14)

if [ "$temp" != "-5.4037" ]; then
  echo "csv failed"
  exit 1
fi

# reverse

$HIMAN -d 5 -f hirlam-rev.json -t csv --no-cuda -s hirlam T-C_pressure_850_pointlist_0_001.csv

lc=`cat T-K_pressure_850_pointlist_0_001.csv | wc -l`

if [ $lc -ne 3 ]; then
  echo "csv failed"
  exit 1
fi

temp=$(grep 25 T-K_pressure_850_pointlist_0_001.csv | cut -d "," -f 14)

if [ "$temp" != "267.746" ]; then
  echo "csv failed"
  exit 1
fi


echo "csv succeed"

rm -f T-C_*.csv T-K*.csv

