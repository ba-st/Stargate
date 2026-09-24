#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR source=.operational-plugin.sh
source "$(dirname "${BASH_SOURCE[0]}")/.operational-plugin.sh"

curl --fail \
  --header "Authorization: Bearer $JWT" \
  --header "Accept: text/plain" \
  "${BASE_URL}":"${PORT}"/operations/application-configuration
