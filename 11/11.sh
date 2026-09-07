#!/bin/bash

cd node-image-data

LAYERS=$(jq -r '.[0].Layers[]' manifest.json)

LAYER_NUM=1
for LAYER in $LAYERS; do
    echo "Đang xử lý Layer $LAYER_NUM: $LAYER"

    DIR_NAME="layer_$(printf "%02d" $LAYER_NUM)"
    mkdir -p "$DIR_NAME"
    

    tar -xf "$LAYER" -C "$DIR_NAME"
    
    LAYER_NUM=$((LAYER_NUM + 1))
done

echo "Hoàn tất giải nén!"