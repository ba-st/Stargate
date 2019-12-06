#!/usr/bin/env bash

source ".operational-plugin.sh"

curl --fail --request POST \
	--header "Authorization: Bearer $JWT" \
	--header "Content-Type:application/json" \
	--header "Accept: application/json" \
	--data '{"jsonrpc": "2.0" ,"method": "shutdown"}' \
	"${BASE_URL}":"${PORT}"/operations/application-control
