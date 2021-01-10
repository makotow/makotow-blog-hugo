#!/bin/bash

TITLE=$1

if [ "${TITLE}" = "" ]; then
    echo "Please specify article title."
    exit 1;
fi

DIR=post/$(date '+%Y/%m/%d')/"${TITLE}"

${HUGO} new -k default "${DIR}"/index.md
