#!/bin/sh

echo "<?xml version="1.0" encoding="UTF-8"?>" >> AmbassadorSecrets.plist
echo "<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">" >> AmbassadorSecrets.plist
echo "<plist version="1.0">" >> AmbassadorSecrets.plist
echo "<dict>" >> AmbassadorSecrets.plist
echo "    <key>PUSHER_DEV_KEY</key>" >> AmbassadorSecrets.plist
echo "    <string>$PUSHER_DEV_KEY</string>" >> AmbassadorSecrets.plist
echo "    <key>PUSHER_PROD_KEY</key>" >> AmbassadorSecrets.plist
echo "    <string>$PUSHER_PROD_KEY</string>" >> AmbassadorSecrets.plist
echo "    <key>SENTRY_KEY</key>" >> AmbassadorSecrets.plist
echo "    <string>$SENTRY_KEY</string>" >> AmbassadorSecrets.plist
echo "</dict>" >> AmbassadorSecrets.plist
echo "</plist>" >> AmbassadorSecrets.plist
mv /AmbassadorSecrets.plist /Ambassador/
