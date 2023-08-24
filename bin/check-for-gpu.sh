#!/bin/sh

gpu_name=$(nvidia-smi -L)

if [ $? -eq 0 ]; then
    echo "Found GPU: $gpu_name"
    exit 0
else
    echo "No GPU found on this machine"
    exit 1
fi
