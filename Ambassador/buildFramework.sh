#!/bin/sh

#if [ "$CIRCLE_BRANCH" == *"release"*]
 #  then
      #mkdir $CIRCLE_ARTIFACTS/Framework_files
      xcodebuild -workspace Ambassador.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=latest,name=iPhone 6' -configuration Release -scheme Framework -derivedDataPath DerivedDataclean build 
     
      for file in /DerivedData/Ambassador/Build/Products/Release-iphoneos/*; do
        echo ${file##*/} 
      done

      cp /DerivedData/Ambassador/Build/Products/Release-iphoneos/Ambassador.framework $CIRCLE_ARTIFACTS/Ambassador.framework
#fi
