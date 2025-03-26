#!/bin/bash

source $(dirname $0)/environment+variables.sh

swift package --disable-sandbox preview-documentation --target $TARGET_NAME