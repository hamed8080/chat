swift test \
    --enable-code-coverage \
    --parallel --num-workers 2 \

xcodebuild test \
-scheme ChatDTO \
-sdk iphonesimulator \
-destination 'platform=iOS Simulator,name=iPhone 14,OS=16.4'
CODE_SIGN_IDENTITY="" \
CODE_SIGN_ENTITLEMENTS="" \
CODE_SIGNING_REQUIRED="NO" \
CODE_SIGNING_ALLOWED="NO"


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
