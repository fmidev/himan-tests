#!/bin/sh

set -uxe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

$HIMAN -d 5 -f bbox.json --no-cuda -t querydata bbox.grib

qdmissing -e 1 bbox.json.fqd

if [ $? -eq 0 ];then
  echo bbox success!
else
  echo bbox failed
  exit 1
fi

rm -f *.fqd
