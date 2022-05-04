#!/usr/bin/env bash

pid=0

# SIGTERM-handler
termination_handler() {
  exit_status=0
  if [ $pid -ne 0 ]; then
    echo 'SIGTERM was received, stopping the API'
  	curl --silent --fail --request POST \
      --header "Authorization: Bearer $APPLICATION_CONTROL_TOKEN" \
      --header "Content-Type:application/json" \
      --header "Accept: application/json" \
      --data '{"jsonrpc": "2.0" ,"method": "shutdown"}' \
      http://localhost:"${STARGATE__PORT}"/operations/application-control
    wait "$pid"
    exit_status=$?
  fi
  exit "$exit_status"
}

trap 'termination_handler' SIGTERM
./api-start.sh &
pid="$!"
wait "$pid"
