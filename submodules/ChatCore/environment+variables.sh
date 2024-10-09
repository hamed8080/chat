#!/bin/bash

TARGET_NAME="ChatCore"
LOWERCASE_TARGET_NAME=$(echo $TARGET_NAME | awk '{print tolower($0)}')
BUNDLE_ID="ir.${TARGET_NAME}"
BUNDLE_VERSION="1.0.1"
DOCC_FILE_PATH="${pwd}/ChatCore/ChatCore.docc"
DOCC_HOST_BASE_PATH="${LOWERCASE_TARGET_NAME}"
DOCC_OUTPUT_FOLDER="./docs"
DOCC_BRANCH_NAME="gh-pages"
HOST_BASE_PATH="chat-core"
DOCC_DATA="docsData"
DOCC_ARCHIVE="doccArchive"
GITHUB_USER_NAME="hamed8080"
ROOT_DIR=$(pwd)
RESULT_BUNDLE_PATH=".build/ResultBundle.xcresult"
CODE_COVERAGE_PATH="codecov.json"
