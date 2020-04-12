#!/bin/bash

BASE_URL=${BASE_URL:=$(1)}
${HUGO} server --disableFastRender --gc --debug --bind 0.0.0.0 --baseURL ${BASE_URL}

