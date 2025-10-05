#!/bin/bash

if [ "$#" != "0" ]; then
    echo "Usage: $0 < PHOTO_IDS.TXT"
    exit 1
fi

while read photo_id; do
    echo $photo_id
    flickcurl photos.setPerms $photo_id yes no no "" ""
done
