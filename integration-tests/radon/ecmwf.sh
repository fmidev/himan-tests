#!/bin/sh

set -uxe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

rm -f ecmwf.json.fqd ecmwf-global.json.fqd

export MASALA_PROCESSED_DATA_BASE=$PWD
export MASALA_RAW_DATA_BASE=$MASALA_PROCESSED_DATA_BASE
export PGPASSWORD=$RADON_WETODB_PASSWORD
export PGHOST=$RADON_HOSTNAME
export PGUSER=radon_admin
export PGDATABASE=radon
export PGPORT=$RADON_PORT

if [ $(echo $RADON_HOSTNAME | grep -c "radondb") -gt 0 ]; then
  echo "attempting to access production database"
  exit 1
fi

set +e

grid_to_radon

ret=$?

if [ $ret -ne 0 ]; then
  # a workaround for the situation where himan-headers or dependencies have updated,
  # and we need to build new radon-tools version but it cannot be done without himan
  # rpms.
  # if grid_to_radon does not work correctly without any arguments, bypass this test.
  exit 0
fi

set -e

echo "DELETE FROM table_meta_grid" | psql -Aqt
echo "INSERT INTO table_meta_grid (producer_id,schema_name,table_name,geometry_id,retention_period, analysis_times) VALUES (131, 'data', 'grid_ecg', 1007, interval '1 hour', '{0}')" | psql -Aqt

radon_tables.py --host $RADON_HOSTNAME --port $RADON_PORT -r 131 -d 20191217

echo "DELETE FROM data.grid_ecg" | psql -Aqt

grid_to_radon -v ecmwf-source.grib

$HIMAN -d 5 -f ecmwf.json --no-cuda -s stat -t querydata 

qdmissing -e 1 ecmwf.json.fqd

if [ $? -eq 0 ];then
  echo radon/ecmwf success!
else
  echo radon/ecmwf failed
  exit 1
fi

$HIMAN -d 5 -f ecmwf-global.json --no-cuda -s stat -t querydata 

qdmissing -e 1 ecmwf-global.json.fqd

if [ $? -eq 0 ];then
  echo radon/ecmwf success!
else
  echo radon/ecmwf failed
  exit 1
fi

rm -rf 131 ecmwf.json.fqd ecmwf-global.json.fqd
