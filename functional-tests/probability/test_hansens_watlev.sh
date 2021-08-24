#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f hansens_watlev.fqd

$HIMAN -d 5 -f hansens_watlev.json --no-cuda hansens_watlev_source.csv

qddifference -e 1 hansens_watlev.json.fqd hansens_watlev_result.fqd

if [ $? -eq 0 ]; then
	echo probability/hansens_watlev success on CPU!
else
	echo probability/hansens_watlev failed on CPU!
	exit 1
fi
