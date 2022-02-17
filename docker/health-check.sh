#!/usr/bin/env bash

curl --fail --request POST \
  --header "Authorization: Bearer $HEALTH_CHECK_TOKEN" \
  --header "Accept: application/vnd.stargate.health-check.summary+json;version=1.0.0" \
  http://localhost:"$STARGATE_PORT"/operations/health-check || exit 1
