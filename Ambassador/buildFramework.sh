#!/bin/sh

#if [ "$CIRCLE_BRANCH" == *"release"*]
 #  then
      #mkdir $CIRCLE_ARTIFACTS/Framework_files
      xcodebuild -workspace Ambassador.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=latest,name=iPhone 6' -configuration Release -scheme Framework -derivedDataPath build clean build 
      mv /Users/distiller/ambassdor-ios-sdk/build/Build/Products/Release-iphoneos/Ambassador.framework $CIRCLE_ARTIFACTS/Ambassador.framework
#fi
