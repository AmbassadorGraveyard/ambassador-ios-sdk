#!/bin/sh

echo "<?xml version="1.0" encoding="UTF-8"?>" >> AmbassadorSecrets.plist
echo "<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">" >> Ambassador/AmbassadorSecrets.plist
echo "<plist version="1.0">" >> Ambassador/AmbassadorSecrets.plist
echo "<dict>" >> AmbassadorSecrets.plist
echo "    <key>PUSHER_DEV_KEY</key>" >> Ambassador/AmbassadorSecrets.plist
echo "    <string>$PUSHER_DEV_KEY</string>" >> Ambassador/AmbassadorSecrets.plist
echo "    <key>PUSHER_PROD_KEY</key>" >> Ambassador/AmbassadorSecrets.plist
echo "    <string>$PUSHER_PROD_KEY</string>" >> Ambassador/AmbassadorSecrets.plist
echo "    <key>SENTRY_KEY</key>" >> Ambassador/AmbassadorSecrets.plist
echo "    <string>$SENTRY_KEY</string>" >> Ambassador/AmbassadorSecrets.plist
echo "</dict>" >> Ambassador/AmbassadorSecrets.plist
echo "</plist>" >> Ambassador/AmbassadorSecrets.plist
