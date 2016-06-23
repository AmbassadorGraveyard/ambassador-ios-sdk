#!/bin/sh

#fail if err occurs on any step
set -o errexit

if [ "$CIRCLE_BRANCH" == "rainforest" ]
   then 
     rainforest validate --token $RAINFOREST_TOKEN
     rainforest upload --token $RAINFOREST_TOKEN

     GITHUB_PULL_NUMBER=$(echo $CI_PULL_REQUEST | awk -F/ '{print $7}')
     rainforest run --fg --fail-fast --git-trigger --token $RAINFOREST_TOKEN --browsers iphone_6s_v9_0 --app-source-url https://s3-us-west-2.amazonaws.com/ambassador-rainforest/Ambassador.ipa
fi
