#!/bin/sh

set -uxe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan"
fi

export HIMAN_DEBUG_LEVEL=5
export HIMAN_NO_CUDA=true
export HIMAN_OUTPUT_FILE_TYPE=querydata
export HIMAN_CONFIGURATION_FILE=bbox.json
export HIMAN_AUXILIARY_FILES="bbox.grib"

$HIMAN

qdmissing -e 1 bbox.json.fqd

if [ $? -eq 0 ];then
  echo environment success!
else
  echo environment failed
  exit 1
fi

rm -f *.fqd
