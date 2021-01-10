#!/bin/bash


if [ $# != 2 ] || [ $1 = "" ] || [ $2 = "" ]; then
  echo "Two parameters are required"
  echo ""
  echo "SRC: path to eye catch image file"
  echo "DST: path to resized image file name"
  echo ""
  echo "example command"
  echo "\t$ ./hack/eyecatch-resize.sh ./path/to/imagefile ./static/images/YYYMMDD/dst.jpg"
  exit
fi

SRC=$1
DST=$2

convert -resize 1920x1080! $SRC $DST
