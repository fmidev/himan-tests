#!/bin/sh

set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/build/debug/himan"
fi

rm -f hansens_watlev.fqd a b

$HIMAN -d 5 -f hansens_watlev.json --no-cuda hansens_watlev_source.csv

# Note: qddifference does not work anymore
# qddifference -e 1 hansens_watlev.json.fqd hansens_watlev_result.fqd

qdstat hansens_watlev.json.fqd > a
qdstat hansens_watlev_result.fqd > b

diff -u a b

if [ $? -eq 0 ]; then
	echo probability/hansens_watlev success on CPU!
else
	echo probability/hansens_watlev failed on CPU!
	exit 1
fi

rm -f hansens_watlev.fqd a b
