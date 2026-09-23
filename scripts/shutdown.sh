#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR source=.operational-plugin.sh
source "$(dirname "${BASH_SOURCE[0]}")/.operational-plugin.sh"

curl --fail --request POST \
	--header "Authorization: Bearer $JWT" \
	--header "Content-Type:application/json" \
	--header "Accept: application/json" \
	--data '{"jsonrpc": "2.0" ,"method": "shutdown"}' \
	"${BASE_URL}":"${PORT}"/operations/application-control
