#!/bin/sh

#if [ "$CIRCLE_BRANCH" == *"release"*]
 #  then
      xcodebuild -workspace Ambassador.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=latest,name=iPhone 6' -configuration Release -scheme Framework clean build 
      mkdir $CIRCLE_ARTIFACTS/Framework_files
      cp Users/distiller/Library/Developer/Xcode/DerivedData/ $CIRCLE_ARTIFACTS/Framework_files
#fi
