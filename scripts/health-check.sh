#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR source=.operational-plugin.sh
source "$(dirname "${BASH_SOURCE[0]}")/.operational-plugin.sh"

curl --fail --request POST \
  --header "Authorization: Bearer $JWT" \
  --header "Accept: application/vnd.stargate.health-check.summary+json;version=1.0.0" \
  "${BASE_URL}":"${PORT}"/operations/health-check
