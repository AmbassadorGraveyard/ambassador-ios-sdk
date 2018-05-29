#!/bin/sh

# fail if err occurs on any step
set -o errexit

rainforest run --run-group 1728 --fail-fast --token "$RAINFOREST_TOKEN" --description "Ambassador iOS Demo App automated post deploy run (Production)" --bg

