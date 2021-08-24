cnt=$($HIMAN -l | grep -c Plugin)

if [ $cnt -lt 48 ]; then
    echo "plugin count was less than expected"
    exit 1
fi
