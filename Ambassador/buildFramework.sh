#!/bin/sh

#if [ "$CIRCLE_BRANCH" == *"release"*]
 #  then
      #mkdir $CIRCLE_ARTIFACTS/Framework_files
      xcodebuild -workspace Ambassador.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=latest,name=iPhone 6' -configuration Release -scheme Framework -derivedDataPath $CIRCLE_ARTIFACTS clean build 
      #cp Users/distiller/Library/Developer/Xcode/DerivedData/ $CIRCLE_ARTIFACTS/Framework_files
#fi
