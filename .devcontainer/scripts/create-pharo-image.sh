#!/usr/bin/env bash
#
# Create the working Pharo image this devcontainer develops against.
#
# The container carries a pristine Pharo image under /opt/pharo/pristine. That
# copy is effectively read-only: it lives in the container filesystem, and a
# rebuild replaces it. The working copy lives in the repository instead, so it
# survives rebuilds and volume pruning, stays visible from the host, and can be
# thrown away and recreated without rebuilding anything.

set -euo pipefail

readonly PRISTINE_DIR=/opt/pharo/pristine
readonly DEFAULT_IMAGE_DIR=/Stargate/pharo

usage() {
  cat <<'USAGE'
Usage: create-pharo-image.sh [--force]

Copy the pristine Pharo image into the working image directory, unless a
working image is already there.

  --force   Discard the working image and its changes file first, then copy a
            fresh one. Whatever is saved in that image and not committed to git
            is lost.
  --help    Show this message.

The working image directory is /Stargate/pharo, or $PHARO_IMAGE_DIR
when that variable is set.
USAGE
}

main() {
  local force=false

  while (("$#" > 0)); do
    case "$1" in
      --force) force=true ;;
      --help | -h)
        usage
        return 0
        ;;
      *)
        printf 'Unknown argument: %s\n\n' "$1" >&2
        usage >&2
        return 2
        ;;
    esac
    shift
  done

  if [[ ! -d $PRISTINE_DIR ]]; then
    printf 'No pristine image under %s. Is this running inside the devcontainer?\n' \
      "$PRISTINE_DIR" >&2
    return 1
  fi

  local image_dir="${PHARO_IMAGE_DIR:-$DEFAULT_IMAGE_DIR}"

  if [[ -f "$image_dir/Pharo.image" ]]; then
    if [[ $force == false ]]; then
      printf 'A working image is already in %s; leaving it alone.\n' "$image_dir"
      return 0
    fi
    printf 'Discarding the working image in %s.\n' "$image_dir"
    rm --force "$image_dir/Pharo.image" "$image_dir/Pharo.changes"
  fi

  mkdir --parents "$image_dir"
  cp --archive "$PRISTINE_DIR/." "$image_dir/"
  chmod u+w "$image_dir/Pharo.image" "$image_dir/Pharo.changes"

  # pharo.version holds the image family, "130". The sources file name carries
  # the version and the build it was cut from, which is the useful thing.
  printf 'Created a working %s image in %s.\n' \
    "$(basename "$PRISTINE_DIR"/Pharo*.sources .sources)" "$image_dir"
}

main "$@"
