#!/bin/bash

# Run SwiftLint on all files in the repository
if which swiftlint >/dev/null; then
  swiftlint --strict --config ".swiftlint.yml" Sources
else
  echo "error: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
  exit 1
fi

# If the SwiftLint command fails, exit with a non-zero status
if [ $? -ne 0 ]; then
  echo -e "\033[31merror: SwiftLint failed\033[0m"
  exit 1
fi