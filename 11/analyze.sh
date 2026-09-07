#!/bin/bash

cd node-image-data

for LAYER_DIR in layer_*; do
  


    echo " CÁC FILE BỊ XÓA:"
    DELETED_FILES=$(find "$LAYER_DIR" -type f -name ".wh.*")
    
    if [ -z "$DELETED_FILES" ]; then
        echo "  (Không có file nào bị xóa)"
    else
        for file in $DELETED_FILES; do

            clean_name=$(echo "$file" | sed 's/\.wh\.//g')
            echo "  - $clean_name"
        done
    fi

    echo ""


    echo " CÁC FILE ĐƯỢC THÊM / SỬA "
    ADDED_FILES=$(find "$LAYER_DIR" -type f ! -name ".wh.*" )
    
    if [ -z "$ADDED_FILES" ]; then
        echo "  (Không có file nào)"
    else
        for file in $ADDED_FILES; do
            echo "  + $file"
        done
        

       
    fi
    echo ""
done