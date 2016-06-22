#!/bin/sh

xcodebuild archive -project Ambassador.xcworkspace -scheme DemoApp -archivePath Ambassador.xcarchive

xcodebuild -exportArchive -archivePath Ambassador.xcarchive -exportPath $CIRCLE_ARTIFACTS/IPAs/Ambassador.ipa -exportFormat ipa -exportProvisioningProfile "Ambassador SDK Application"
