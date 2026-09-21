# Develop in the Pharo image

Recipes for the Pharo side of the devcontainer: opening the IDE, running the
image headless, loading code into it, and starting over when an image gets
wedged.

The devcontainer ships the VM and a pristine Pharo image; the image you actually
work in lives in `pharo/`, which is gitignored. It is created for you when the
container is created.

## Open the IDE

Inside the container, that is the whole of it:

```bash
pharo-ui &
```

The IDE opens on your desktop. `pharo-ui` passes everything after it to Pharo,
and reads `PHARO_IMAGE` if you want a different image than the one in
`pharo/`.

It draws on the X server of the machine running Docker, over the socket
bind-mounted at `/tmp/.X11-unix`, and needs `DISPLAY` to name that server.
`DISPLAY` is inherited from the shell that started the devcontainer and is not
defaulted, because guessing is worse than failing: on a Plasma Wayland session
the session's own XWayland server is `:1`, and `:0` belongs to something else
and refuses the connection. Set it in `.devcontainer/.env` if your shell has
none.

No `xhost` call is normally needed — the X server already admits the uid the
container draws as. If it does not, see the last section.

## Run the image headless

Same image, no window:

```bash
pharo eval "3 + 4"
pharo test --junit-xml-output "Stargate-*"
pharo metacello install github://ba-st/Buoy:release-candidate/source BaselineOfBuoy
```

`pharo` takes the same arguments as the `pharo` command in ba-st's runtime
image, so anything written for CI runs here unchanged.

The pattern `pharo test` takes is a **glob**, matched against package names, not
a regular expression: `Stargate-*` selects every Stargate package, while
`Stargate-.*` selects none — and a run that matched nothing reports no failures,
so it reads as a pass.

## Load this project's code

The working image loads Stargate from this repository, not from GitHub. Which
URL you give Metacello decides whether it reads the working tree or the last
commit:

```bash
# The working tree, uncommitted edits included.
pharo metacello install tonel:///Stargate/source BaselineOfStargate --groups=Development

# What git has committed on the current branch.
pharo metacello install gitlocal://./source BaselineOfStargate --groups=CI
```

`gitlocal://` goes through Iceberg, which reads packages out of the commit: a
package that exists only on disk fails the load with
`KeyNotFound: key 'BaselineOf…' not found`, and an edit you have not committed
is quietly not loaded. Use it to reproduce what CI sees; use `tonel://` while
you are still working.

## Load dependencies without cloning them twice

Metacello loads a `github://` project by having Iceberg clone it, and every
dependency in the tree gets a clone of its own. Those clones are shared between
every image in this container, in `/home/node/iceberg`, which is a named volume:
they outlive a container rebuild, a fresh working image, and a
`git clean -xdf` of the repository. Load a project once and the next image
fetches rather than clones.

```bash
pharo metacello install github://ba-st/Buoy:release-candidate/source BaselineOfBuoy
```

Nothing needs enabling — the pristine image is built with
`IceLibgitRepository shareRepositoriesBetweenImages: true`, and every working
image inherits it. To confirm where a given image is putting them:

```bash
pharo eval "IceLibgitRepository repositoriesLocation fullName"
```

An image that answers a path under `pharo-local/` is not sharing, and will
clone the whole tree for itself.

### Keeping the clones somewhere you can reach

By default they sit in a Docker-managed volume, which the host cannot browse.
To put them in a directory of your own instead, create it on the host **first**
and then name it in `.devcontainer/.env`:

```bash
mkdir --parents /home/you/pharo-iceberg    # on the host
echo 'ICEBERG_REPOSITORIES_DIR=/home/you/pharo-iceberg' >> .devcontainer/.env
```

Rebuild, and the same path is a bind mount rather than a volume; unset it again
and the volume comes back with its contents intact. Creating the directory
first is the part that matters: Docker creates a missing bind-mount source as
root, the container writes as uid 1000, and Iceberg's only complaint about a
directory it cannot write to is `PrimitiveFailed: primitive #createDirectory:
in UnixStore failed`, which names neither the path nor the reason.
`check-iceberg-repositories.sh` runs on container creation and says it plainly
instead; run it any time to check.

Two things this does not cover. The Monticello package cache stays per-image in
`pharo/pharo-local/package-cache`, which is fine — it is small, and it
rides along on the repository bind mount. And the clones carry **SSH** remotes,
so fetching them depends on VS Code forwarding your SSH agent into the
container; `ssh-add -l` shows whether it did.

## Start over with a fresh image

Nothing in `pharo/` is tracked, so a wedged image costs nothing to
throw away:

```bash
create-pharo-image.sh --force
```

That deletes `Pharo.image` and `Pharo.changes` and copies the pristine pair back
in. Anything saved in the image and not committed to git goes with them, so
commit through Iceberg first. Without `--force` the script leaves an existing
image alone, which is why it is safe to rerun and why it runs on every rebuild.

To leave the working image where it is and check a load in a clean one, put the
copy somewhere else with `PHARO_IMAGE_DIR` and point `PHARO_IMAGE` at it:

```bash
PHARO_IMAGE_DIR=/tmp/fresh create-pharo-image.sh --force
PHARO_IMAGE=/tmp/fresh/Pharo.image pharo metacello install \
  gitlocal://./source BaselineOfStargate --groups=CI
PHARO_IMAGE=/tmp/fresh/Pharo.image pharo test --junit-xml-output "Stargate-*"
```

## When the window does not appear

- **`pharo-ui: DISPLAY is unset`** — the shell that started the devcontainer had
  no `DISPLAY`. Set it in `.devcontainer/.env` and rebuild.
- **`Authorization required, but no authorization protocol specified`** — the X
  server named by `DISPLAY` will not admit the container. Check you are pointing
  at your own session's server: with several sockets in `/tmp/.X11-unix`, the one
  your session owns is the one owned by your uid. Failing that, run
  `xhost +SI:localuser:$(id -un 1000)` on the host once per login session, which
  admits exactly the uid the container draws as and nothing else. `xhost` is
  `xorg-xhost` on Arch and Manjaro, `x11-xserver-utils` on Debian and Ubuntu.
- **`MESA: error: Failed to query drm device` and no window** — the container has
  no `/dev/dri`, so Mesa cannot make a hardware GL screen. `pharo-ui` already
  sets `LIBGL_ALWAYS_SOFTWARE=1` for this; if you have overridden it, don't.
- **The image runs but never opens a window, printing nothing at all** — that is
  the signature of a headless-only VM, not a display problem. Do not try to
  confirm it with `pharo eval "Smalltalk isHeadless"`: the `pharo` wrapper passes
  `--headless` itself, so the answer is always `true` and says nothing about the
  VM. What to check is which VM you are running. The one this container builds,
  in the `pharo-vm` stage of `.devcontainer/Dockerfile`, comes from the
  `pharo-spur64` build and opens windows; a `pharo-spur64-headless` build, which
  is what ba-st's runtime image ships, writes `--headless` into every image's
  arguments and cannot open one whatever it is asked for. `--interactive` will
  not fix it.
- **Do not debug this by invoking the VM yourself** —
  `/opt/pharo/vm/pharo <image> eval ...`, without `--headless` and without a
  display it can reach, idles forever with no output and no error, and leaves a
  second VM on your working image. `pharo` and `pharo-ui` exist so that neither
  happens.
- **Two IDEs on one image** — nothing prevents it, and two VMs writing one
  `.changes` file corrupts it. `ps -eo args | grep vm/lib/pharo` lists them.
