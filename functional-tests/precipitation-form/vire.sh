set -x

if [ -z "$HIMAN" ]; then
	export HIMAN="../../himan-bin/himan"
fi

rm -f fc*.grib

$HIMAN -d 4 -f vire.json source_vire.grib -s stat --no-cuda

grib_compare fc202506160100+021h00m.grib result_vire.grib2

if [ $? -ne 0 ];then
  echo precipitation-form/vire failed on CPU
  exit 1
fi

echo precipitation-form/vire success on CPU
rm -f fc*.grib
