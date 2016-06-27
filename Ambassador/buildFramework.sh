y#!/bin/sh

#if [ "$CIRCLE_BRANCH" == *"release"*]
 #  then
      #mkdir $CIRCLE_ARTIFACTS/Framework_files
      xcodebuild -workspace Ambassador.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=latest,name=iPhone 6' -configuration Release -scheme Framework -derivedDataPath DerivedDataclean build 
      mv /Users/distiller/ambassador-ios-sdk/Ambassador/DerivedData/Build/Products/Release-iphoneos/Ambassador.framework $CIRCLE_ARTIFACTS/Ambassador.framework
      mv /Users/distiller/ambassador-ios-sdk/Ambassador/DerivedData/Build/Products/Release-iphoneos/Ambassador.bundle $CIRCLE_ARTIFACTS/Ambassador.bundle
#fi
