set -u

data=$1

if [ ! -f "$data" ]; then
  echo "data $data not present, copying it from lake.fmi.fi"
  set -ex
  curl --retry 1 https://lake.fmi.fi/himan-tests-source-data/$data -o $data
fi
