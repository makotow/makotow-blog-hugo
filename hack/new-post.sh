#!/bin/bash

TITLE=$1

if [ "${TITLE}" = "" ]; then
    echo "Please specify artcile title."
    exit 1;
fi

DIR=post/$(date '+%Y/%m/%d')/"${TITLE}"

hugo new -k default "${DIR}"/index.md
mkdir -p content/"${DIR}"/images
