#!/bin/bash

if [ $# != 1 ] || [ $1 = "" ]; then
  echo "One parameters are required"
  echo ""
  echo "string: path to markdown file of target post"
  echo ""
  echo "example command"
  echo "\t$ sh ./hack/tcardgen.sh ./content/post/2020/12/30/directory/index.md"
  exit
fi

TARGET_POST_PATH=$1

FONT_DIR=./static/asset/fonts/kinto-sans
DIR_PATH=$(dirname "$TARGET_POST_PATH")
FILE_PATH=$(echo $DIR_PATH | sed -e 's/.\/content\/post\///g')
echo $FILE_PATH

OGP_OUTPUT_FILE_PATH=./static/images/tcard/$FILE_PATH
TEMPLATE_FILE=./static/asset/tcard-template/template.png
TCARD_CONF=./tcardgen.yaml

mkdir -p "$OGP_OUTPUT_FILE_PATH"

tcardgen \
--fontDir "$FONT_DIR"  \
--output "$OGP_OUTPUT_FILE_PATH" \
--template "$TEMPLATE_FILE" \
--config "$TCARD_CONF" \
"$TARGET_POST_PATH"