#!/bin/sh

# fail if err occurs on any step
set -o errexit

rainforest run --run-group 1655 --fail-fast --site 8412 --token "$RAINFOREST_TOKEN" --description "Ambassador App automated post deploy run" --bg

