#!/bin/sh

# fail if err occurs on any step
set -o errexit

rainforest run --run-group 1655 --fail-fast --environment-id 5165 --token "$RAINFOREST_TOKEN" --description "Ambassador iOS Demo App automated post deploy run (Staging)" --bg

