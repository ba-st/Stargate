#!/usr/bin/env bash

source ".operational-plugin.sh"

curl --fail \
  --header "Authorization: Bearer $JWT" \
  --header "Accept: text/plain" \
  "${BASE_URL}":"${PORT}"/operations/application-configuration
