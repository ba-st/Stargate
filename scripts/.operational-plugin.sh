#!/usr/bin/env bash

usage()
{
  if [ "$*" != "" ] ; then
       echo "Error: $*"
   fi

   cat << EOF
Usage: $(basename $0) [-b BASE_URL] [-p PORT] -t JWT
This program will interact with an Stargate powered API using some operational plugin endpoint.
Options:
-b BASE_URL         Base URL where the API is hosted. Defaults to http://localhost
-p PORT             Port where the API is running. Defaults to 8080.
-t JWT              JSON Web Token including the required permissions.
-h                  Display this usage message and exit.
Example:
   $(basename $0) -b http://api.example.com -p 80 -t eyJhbGciOiJIUzI1NiJ9.eyJzY29wZSI6ImV4ZWN1dGU6YXBwbGljYXRpb24tY29udHJvbCJ9.RPtv3mxtaaw+vgRHsZ1cpD59IMvRGw7oCoX2YU767Vk
EOF

   exit 1
}

# Exit and show help if the command line is empty
[[ ! "$*" ]] && usage "Not enough arguments"

# Initialise options
BASE_URL_OPTION=""
PORT_OPTION=""
JWT_OPTION=""
# Parse command line options
while getopts "b:p:t:h" option; do
  case $option in
    b) BASE_URL_OPTION=$OPTARG ;;
    p) PORT_OPTION=$OPTARG ;;
    t) JWT_OPTION=$OPTARG ;;
    h) usage ;;
  esac
done
shift $(($OPTIND - 1)); # take out the option flags

readonly BASE_URL="${BASE_URL_OPTION:-http://localhost}"
readonly PORT="${PORT_OPTION:-8080}"
readonly JWT="$JWT_OPTION"
if [ -z "$JWT" ] ; then
  usage "The token is mandatory"
fi
