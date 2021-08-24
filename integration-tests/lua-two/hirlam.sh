#!/bin/sh

set -xe

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

# this test only checks that himan execution passes (since that was a problem after kFloatMissing change)
$HIMAN -d 4 -f luatool.json luatool.grib -s --no-cuda --no-auxiliary-file-full-cache-read

rm -f RHICE* TF-C*
