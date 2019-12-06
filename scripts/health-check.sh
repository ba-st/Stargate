#!/usr/bin/env bash

source ".operational-plugin.sh"

curl --fail --request POST \
  --header "Authorization: Bearer $JWT" \
  --header "Accept: application/vnd.stargate.health-check.summary+json;version=1.0.0" \
  "${BASE_URL}":"${PORT}"/operations/health-check
