# The pristine Pharo image, taken from the ba-st runtime image so it is exactly
# the one ba-st's own CI runs. A build stage rather than the base image or a
# service of its own: what ba-st publishes runs as uid 7431 on debian-slim with
# none of the X client libraries.
#
# Only the image files are taken from it. The VM it ships is built from
# pharo-spur64-headless, which puts --headless into every image's arguments
# whatever it is asked for, and Pharo decides whether to open a window by
# scanning its own arguments for exactly that token
# (SmalltalkImage>>#isHeadless) — so that VM cannot open the IDE at all, and no
# flag makes it. The VM comes from the stage below instead.
FROM ghcr.io/ba-st/pharo:v13.1.2 AS pharo-image

# The UI-capable VM, from the pharo-spur64 build rather than
# pharo-spur64-headless. It still runs headless when handed --headless
# explicitly, which is what the pharo wrapper does, so one VM serves both.
#
# stable12 is a moving pointer, updated on each stable 12.x release, and that is
# deliberate: the VM follows its stable line rather than being frozen. The cost
# is that this stage is not reproducible — two builds of the same commit can
# fetch different VMs — so when a rebuild changes VM behaviour, this is the line
# that changed under it. Docker caches the layer, so an existing image keeps its
# VM until the stage is rebuilt without cache. Pass PHARO_VM_URL to pin a
# specific build instead; the immutable ones sit beside it in the same
# directory, named PharoVM-<version>-Linux-x86_64-stockReplacement-bin.zip.
FROM debian:13-slim AS pharo-vm
ARG PHARO_VM_URL=https://files.pharo.org/vm/pharo-spur64/Linux-x86_64/stable12.zip
RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
  && mkdir --parents /opt/pharo/vm \
  && curl --fail --silent --show-error --location "${PHARO_VM_URL}" \
    --output /tmp/pharo-vm.zip \
  && unzip -q /tmp/pharo-vm.zip -d /opt/pharo/vm \
  && rm /tmp/pharo-vm.zip \
  && rm --recursive --force /var/lib/apt/lists/*

FROM mcr.microsoft.com/devcontainers/javascript-node:24-trixie

# Install dependencies.
#
# libx11-6 and libxext6 are what the libSDL2 bundled with the VM dlopens when it
# opens a window; everything else the IDE draws with — cairo, freetype,
# fontconfig, harfbuzz — ships inside the VM, as do the libgit2 and libssh2
# Iceberg needs. fonts-dejavu-core just gives fontconfig something to fall back
# on, since the base image ships no fonts at all.
#
# libgl1 brings libGL.so.1, and libgl1-mesa-dri the software rasteriser behind
# it. Both are needed: the container has no /dev/dri, so Mesa cannot create a
# DRI3 screen and window creation fails outright unless it can fall back to
# software, which is why pharo-ui sets LIBGL_ALWAYS_SOFTWARE.
RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
    fonts-dejavu-core \
    libgl1 \
    libgl1-mesa-dri \
    libx11-6 \
    libxext6 \
    shellcheck \
    yamllint \
  && rm --recursive --force /var/lib/apt/lists/*

# Create the shell history mount point up front so the named volume inherits
# node ownership instead of being created as root.
RUN mkdir --parents /commandhistory \
  && chown node:node /commandhistory

# The VM, and the pristine image create-pharo-image.sh copies into the
# repository. Pharo* picks up the image, the changes file and the sources file,
# whose name carries the build it came from.
COPY --from=pharo-vm --chown=node:node /opt/pharo/vm /opt/pharo/vm
COPY --from=pharo-image --chown=node:node /opt/pharo/Pharo* \
  /opt/pharo/pharo.version /opt/pharo/pristine/

COPY scripts/check-iceberg-repositories.sh scripts/create-pharo-image.sh \
  scripts/pharo scripts/pharo-ui /usr/local/bin/
RUN chmod a+x \
  /usr/local/bin/check-iceberg-repositories.sh \
  /usr/local/bin/create-pharo-image.sh \
  /usr/local/bin/pharo \
  /usr/local/bin/pharo-ui

USER node
WORKDIR /home/node

# Iceberg gives every Metacello dependency a git clone of its own. Left alone it
# puts them beside the image, so each image clones the whole dependency tree
# again; shared between images they are cloned once and fetched thereafter.
# docker-compose.yml mounts a named volume over this directory, so the clones
# also survive a rebuild. Creating it here, owned by node, is what makes that
# volume inherit node ownership instead of being created as root.
RUN mkdir --parents /home/node/iceberg

# Turn the sharing on in the pristine image, so every working image copied from
# it starts out sharing. It is a class variable, so saving the image keeps it,
# and create-pharo-image.sh stays a plain copy.
RUN /opt/pharo/vm/pharo --headless /opt/pharo/pristine/Pharo.image \
  eval --save "IceLibgitRepository shareRepositoriesBetweenImages: true"

# Install markdownlint-cli for linting docs
RUN npm install --global markdownlint-cli@0.49.1

# Install Claude stable (lands in /home/node/.local/bin, already on PATH)
RUN curl --fail --silent --show-error \
  --location https://claude.ai/install.sh --output /tmp/install-claude.sh \
  && bash /tmp/install-claude.sh stable \
  && rm /tmp/install-claude.sh
