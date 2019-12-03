#!/usr/bin/env bash

source ".operational-plugin.sh"

curl --fail \
  --header "Authorization: Bearer $JWT" \
  "${BASE_URL}":"${PORT}"/operations/metrics
