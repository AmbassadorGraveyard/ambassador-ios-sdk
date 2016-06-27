#!/bin/sh

if [ "$CIRCLE_BRANCH" == *"@build_framework"*]
   then
      xcodebuild -workspace Ambassador.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=9.2,name=iPhone 6' -configuration Release -scheme Framework clean build 
      mkdir $CIRCLE_ARTIFACTS/Framework_files
      cp ~/Library/Developer/Xcode/DerivedData/ $CIRCLE_ARTIFACTS/Framework_files
fi
