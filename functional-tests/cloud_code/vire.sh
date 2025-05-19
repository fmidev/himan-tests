set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f fc*.grib

source_data=cloud_consensus_vire_source.grib
../../bin/download-if-not-exists.sh $source_data


$HIMAN -d 4 -f vire.json $source_data -s stat --no-cuda

grib_compare fc202505160700+006h00m.grib2 result_vire.grib2

if [ $? -ne 0 ];then
  echo cloud consensus/vire failed on CPU
  exit 1
fi

echo cloud_consensus/vire success on CPU
rm -f fc*.grib2
rm -f cloud_consensus_vire_source.grib
