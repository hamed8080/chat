#swift test \
#    --enable-code-coverage \
#    --parallel --num-workers 2 \

#swift test \
#    --enable-code-coverage \
#    --parallel --num-workers 2 \

source $(dirname $0)/environment+variables.sh

rm -r "${RESULT_BUNDLE_PATH}"

xcodebuild test \
-scheme "${TARGET_NAME}" \
-sdk iphonesimulator \
-destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
-enableCodeCoverage YES \
-testPlan "${TARGET_NAME}" \
-resultBundlePath "${RESULT_BUNDLE_PATH}" \
CODE_SIGN_IDENTITY="" \
CODE_SIGN_ENTITLEMENTS="" \
CODE_SIGNING_REQUIRED="NO" \
CODE_SIGNING_ALLOWED="NO" | xcpretty && exit ${PIPESTATUS[0]} \
#-derivedDataPath .build/derivedDataPath \

#curl -Os https://uploader.codecov.io/latest/macos/codecov
#
#chmod +x codecov
#./codecov -t ${CODECOV_TOKEN} --xcodeArchivePath codecov.xcresult


#xcrun xccov view --report --json "${RESULT_BUNDLE_PATH}" > "${CODE_COVERAGE_PATH}"


#xcrun xcresulttool get --format json --path "${RESULT_BUNDLE_PATH}" > "${CODE_COVERAGE_PATH}"
#xcrun xccov view .build/derivedDataPath/Logs/Test/*.xccoveragereport


#xcrun llvm-cov export \
#.build/x86_64-apple-macosx/debug/LoggerPackageTests.xctest/Contents/MacOS/LoggerPackageTests \
#-instr-profile=.build/x86_64-apple-macosx/debug/codecov/default.profdata \
#-format=lcov \
#-ignore-filename-regex=".build|Tests" \
#.build/debug/LoggerPackageTests.xctest/Contents/MacOS/LoggerPackageTests > info.lcov

# If you want to make an html pages for code coverage uncomment line below.
# xcrun lcov genhtml info.lcov  --output-directory ./coverage/

#bash <(curl -s https://codecov.io/bash)



#run: xcodebuild clean CODE_SIGN_IDENTITY="" CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_REQUIRED="NO" CODE_SIGNING_ALLOWED="NO" test -workspace Rebtel.xcworkspace -scheme Rebtel -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' -only-testing:RebtelTests | xcpretty && exit ${PIPESTATUS[0]}
