set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f fc*.grib

$HIMAN -d 4 -f vire.json source_vire.grib -s stat --no-cuda

grib_compare fc202504040000+006h00m.grib2 result_vire.grib2

if [ $? -ne 0 ];then
  echo cloud consensus/vire failed on CPU
  exit 1
fi

echo cloud_consensus/vire success on CPU
rm -f fc*.grib2

