#!/usr/bin/env bash
#
# PreToolUse hook for Bash: refuse commands that could print a secret into the
# conversation transcript. See "Secrets" in CLAUDE.md for the rule it enforces.
#
# Reads the hook payload on stdin. Allows by exiting 0 silently; denies by
# printing a PreToolUse permission decision.

set -euo pipefail

# Fail closed: if this script breaks, the command does not run unchecked.
trap 'echo "block-secret-output.sh failed; refusing to run the command unchecked." >&2; exit 2' ERR

command=$(jq --raw-output '.tool_input.command // empty')

deny() {
  jq --null-input --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ($reason + " See the Secrets section of CLAUDE.md.")
    }
  }'
  exit 0
}

# The one sanctioned way to look inside a .env file: its variable names.
names_only='^[[:space:]]*cut[[:space:]]+(-d=|--delimiter==)[[:space:]]+(-f1|--fields=1)[[:space:]]+[^|;&<>$`]*\.env[[:space:]]*$'
if [[ $command =~ $names_only ]]; then
  exit 0
fi

# Any other mention of a .env file, including .env.local and friends, but not
# .env.example, which holds no secrets.
env_file='(^|[^[:alnum:]_])\.env([^[:alnum:]_-]|$)'
without_examples=${command//.env.example/}
if [[ $without_examples =~ $env_file ]]; then
  deny "Commands may not touch .env files; list names only with 'cut --delimiter== --fields=1 <file>'."
fi

# Dumping the whole environment.
separator='(^|[;&|({`]|\$\()[[:space:]]*'
dump_commands="${separator}(printenv|export[[:space:]]+-p|declare[[:space:]]+-[px]|compgen[[:space:]]+-[ev])([^[:alnum:]_-]|\$)"
bare_dumps="${separator}(env|set)[[:space:]]*(\$|[|;&>)])"
proc_environ='/proc/[^[:space:]]*/environ'
if [[ $command =~ $dump_commands || $command =~ $bare_dumps || $command =~ $proc_environ ]]; then
  deny "Commands may not print the environment."
fi

# Expanding a variable whose name says it holds a secret.
secret_variable='\$\{?[[:alnum:]_]*(TOKEN|SECRET|PASSWORD|PASSWD|API_KEY|PRIVATE_KEY|CREDENTIAL)'
if [[ $command =~ $secret_variable ]]; then
  deny "Commands may not expand variables that hold secrets."
fi

# Reading the environment from inside Pharo.
pharo_environment='OSEnvironment|os[[:space:]]+environment'
if [[ $command =~ $pharo_environment ]]; then
  deny "Pharo expressions may not read the environment."
fi

exit 0
