#!/usr/bin/env bash
#
# Warn if the shared Iceberg repositories directory cannot be written to.
#
# It is a mount, so how it fails depends on where it came from. Docker creates a
# missing bind-mount source as root, and everything here runs as node, so
# pointing ICEBERG_REPOSITORIES_DIR at a host directory that does not exist yet
# produces one nothing can clone into. Iceberg's own report of that is
# "PrimitiveFailed: primitive #createDirectory: in UnixStore failed", naming
# neither the directory nor the reason, so it is worth catching here instead.

set -euo pipefail

readonly REPOSITORIES_DIR=/home/node/iceberg

main() {
  if [[ ! -d $REPOSITORIES_DIR ]]; then
    printf 'No %s. docker-compose.yml should be mounting it.\n' \
      "$REPOSITORIES_DIR" >&2
    return 0
  fi

  if [[ -w $REPOSITORIES_DIR ]]; then
    return 0
  fi

  local owner running_as
  owner=$(stat --format '%U:%G' "$REPOSITORIES_DIR")
  running_as="$(id --user --name) ($(id --user))"

  cat >&2 <<WARNING

  WARNING: Iceberg cannot write to its repositories directory, so Metacello
  will fail to load anything, reporting only:

      PrimitiveFailed: primitive #createDirectory: in UnixStore failed

      directory: $REPOSITORIES_DIR
      owned by:  $owner
      we are:    $running_as

  If ICEBERG_REPOSITORIES_DIR is set in .devcontainer/.env, Docker created that
  host directory as root because it did not exist yet. Create it on the host,
  owned by you, then rebuild the container:

      mkdir --parents <the path you set>

WARNING
  return 0
}

main "$@"
