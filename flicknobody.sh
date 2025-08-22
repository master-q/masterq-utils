#!/bin/bash

for i in {1..59}; do
    echo +++ $i +++++++++
    ret=`flickcurl people.getPublicPhotos 49071064@N00 100 $i | grep "photo with URI" | awk '{ print $6 }'`
    for j in $ret; do
        echo $j
        flickcurl photos.setPerms $j no no no "" ""
    done
done
