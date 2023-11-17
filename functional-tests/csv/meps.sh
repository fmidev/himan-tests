#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f T-C_*.csv T-K*.csv

$HIMAN -d 5 -f meps.json -t csv --no-cuda -s meps meps_source.grib

lc=`cat T-C_pressure_850_pointlist_0_001_4_0.csv | wc -l`

if [ $lc -ne 3 ]; then
  echo "csv failed"
  exit 1
fi

temp=$(grep 25 T-C_pressure_850_pointlist_0_001_4_0.csv | cut -d "," -f 14)

if [ "$temp" != "-10.6686" ]; then
  echo "csv failed"
  exit 1
fi

# reverse

$HIMAN -d 5 -f meps-rev.json -t csv --no-cuda -s meps T-C_pressure_850_pointlist_0_001_4_0.csv

lc=`cat T-K_pressure_850_pointlist_0_001_4_0.csv | wc -l`

if [ $lc -ne 3 ]; then
  echo "csv failed"
  exit 1
fi

temp=$(grep 25 T-K_pressure_850_pointlist_0_001_4_0.csv | cut -d "," -f 14)

if [ "$temp" != "262.481" ]; then
  echo "csv failed"
  exit 1
fi


echo "csv succeed"

rm -f T-C_*.csv T-K*.csv

