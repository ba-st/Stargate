#!/usr/bin/env bash
pid=0
# SIGTERM-handler
termination_handler() {
  if [ $pid -ne 0 ]; then
    echo 'SIGTERM was received, stopping the API'
  	curl --silent --fail --request POST \
      --header "Authorization: Bearer $APPLICATION_CONTROL_TOKEN" \
      --header "Content-Type:application/json" \
      --header "Accept: application/json" \
      --data '{"jsonrpc": "2.0" ,"method": "shutdown"}' \
      http://localhost:"${STARGATE_PORT}"/operations/application-control
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}
trap 'kill ${!}; termination_handler' SIGTERM
./api-start.sh &
pid="$!"
# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
