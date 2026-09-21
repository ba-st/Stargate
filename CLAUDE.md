# Stargate

Stargate is a library supporting the creation of HTTP based RESTful APIs in Pharo and GemStone/64.

## Conventions

Read `CONTRIBUTING.md` before branching, committing, or opening a pull request. It is the source of truth for branch naming, Conventional Commits, the squash-merge strategy, the feature workflow, and the Diátaxis layout of `docs/`. Do not restate those rules here.

## Working on a feature

`CONTRIBUTING.md` defines the workflow: the plan, its phases, one pull request per phase. These are the rules for driving it:

- If `PLAN.md` exists when a session starts, read it before anything else. It is the state of the work in progress.
- Draft the plan, then stop for approval. Open the feature issue only once the user approves it.
- **Never start a phase until the user says to start that phase.** Finishing one phase is not permission to begin the next, even when the plan makes the order obvious.
- After a phase's pull request has been reviewed and merged, write its recap into `PLAN.md`, update the issue to match, and stop.
- After the last phase, run the final review and present what it finds. Leave closing the issue to the user.

## Secrets

**Hard rule: never print the contents of `.devcontainer/.env`, or of any other
`.env` file.** It holds `GH_TOKEN`, and whatever reaches a tool's output lands in
the conversation transcript, which is exactly how that token was exposed once
already. Treat it as write-only:

- Do not `cat`, `head`, `tail`, `less`, `grep`, `sed -n`, `source … && echo`,
  or `Read` it, not even "just to check a setting", and not piped through a
  filter that could still show a value.
- To see *which* variables it sets, print the names only:
  `cut --delimiter== --fields=1 .devcontainer/.env`, exactly that and nothing
  chained to it. To learn a value, ask the user.
- The same applies to the environment the container inherits: never run bare
  `env`, `printenv` or `set`, and never echo `GH_TOKEN` or any variable named
  like a token, password, secret or key.
- `.devcontainer/.env.example` holds no secrets and may be read freely; it is
  the place to learn what `.env` is expected to contain.

`.claude/settings.json` enforces this rather than trusting it to be remembered.
Its `permissions.deny` rules stop the file tools reading or editing `.env`,
`.env.local` and `.env.*.local` anywhere on disk, and a `PreToolUse` hook,
`.claude/hooks/block-secret-output.sh`, refuses any Bash command that mentions
such a file (other than the `cut` above), dumps the environment, expands a
variable named like a secret, or reads the environment from a Pharo expression.
The hook fails closed: if it breaks, the command is blocked. It matches command
text, so it is a guard rail against mistakes, not a sandbox against a
determined workaround. A denial is the rule working; do not route around it.

## Linting

Run inside the devcontainer:

- `markdownlint "**/*.md" --ignore node_modules` — every markdown file, the way
  CI lints them, though CI runs its own copy through `reviewdog`
- `yamllint .`
- `shellcheck <script>`

Both `markdownlint` and `yamllint` already fail on tracked files that predate
this setup — `MD059` in `docs/explanation/Architecture.md` and
`docs/reference/Controllers.md`, indentation in `.github/workflows/unit-tests.yml`
and `.github/workflows/loading-gs64-components.yml`. Read a failure against the
files you touched, not against a clean baseline.

## Pharo

These live in the devcontainer, described in
`docs/how-to/develop-in-the-pharo-image.md`:

- `pharo <args>` — the working image, headless. Same arguments as the `pharo`
  command in ba-st's runtime image, so `pharo eval`, `pharo test` and
  `pharo metacello install` behave the way CI recipes expect.
- `pharo-ui` — the same image in the IDE, on the host's X server.
- `create-pharo-image.sh [--force]` — create the working image in
  `pharo/`, or replace it.

## Source

`source` is Tonel, one directory per package.

Load and test in a fresh image, the way CI does:

```bash
PHARO_IMAGE_DIR=/tmp/fresh create-pharo-image.sh --force   # any scratch directory
PHARO_IMAGE=/tmp/fresh/Pharo.image pharo metacello install \
  gitlocal://./source BaselineOfStargate --groups=CI
PHARO_IMAGE=/tmp/fresh/Pharo.image pharo test --junit-xml-output "Stargate-*"
```

## Gotchas

- Local and CI markdownlint are **different installs that can disagree**: `.devcontainer/Dockerfile` pins `markdownlint-cli@0.49.1`, while `.github/workflows/markdown-lint.yml` runs `reviewdog/action-markdownlint@v0` with whatever version that action bundles. Both read `.markdownlint.json`. Dependabot bumps the action, through the `github-actions` ecosystem, but not the npm pin, which is not a manifest.
- CI runs markdown lint, `shellcheck`, the Pharo unit tests and group loading on Pharo 10–13, and the GS64 unit tests and component loading. `yamllint` is the one linter documented above that runs nowhere but locally. No job builds the devcontainer or exercises its scripts.
- `.github/workflows/markdown-lint.yml` triggers on `pull_request` only, so a push to a branch with no pull request open lints nothing.
- The pattern `pharo test` takes is a **glob** matched against package names — `TestCommandLineHandler` runs `pattern match: packageName` — not a regex. `"Stargate-*"` selects every Stargate package; `"Stargate-.*"` selects none, and a run that matched nothing reports no failures, so it looks like a pass.
- `pharo eval "Smalltalk isHeadless"` always answers `true`, because the `pharo` wrapper passes `--headless` itself. It cannot tell you which VM build you are on. Nor should the VM be invoked directly to find out: without `--headless` and without a reachable display it idles forever, printing nothing, holding your working image open.
- `gitlocal://` loads what git has **committed**, not the working tree: Iceberg reads packages from the commit, so a package that exists only on disk fails with `KeyNotFound: key 'BaselineOf…' not found`, and an uncommitted edit is silently not loaded. Load uncommitted code with `tonel:///Stargate/source` instead.
- `.devcontainer/devcontainer-lock.json` is intentionally gitignored, so devcontainer features are not pinned by digest. The feature versions written in `devcontainer.json` are tracked, by the `devcontainers` ecosystem in `.github/dependabot.yml`.
- `.devcontainer/.env` is gitignored. Copy it from `.env.example`; it sets `REFERENCE_PROJECTS_DIR`, `TZ`, and optionally `DISPLAY`, `ICEBERG_REPOSITORIES_DIR` and `GH_TOKEN`.
- `ghcr.io/ba-st/pharo:v13.1.2` is pinned in `.devcontainer/Dockerfile`, where it
  is a **build stage rather than the base image or a service**, and it supplies
  the **Pharo image only**. Bumping that tag changes the Pharo version
  everything runs on. Dependabot proposes those bumps: `.github/dependabot.yml`
  points the `docker` ecosystem at `/.devcontainer`, which reads every `FROM`,
  build stages included, so this tag, `debian:13-slim` and the Node base image
  all arrive as pull requests.
- **The VM does not come from ba-st, and must not.** ba-st's image ships a VM
  built from `pharo-spur64-headless`, which writes `--headless` into every
  image's argument list no matter what it is asked for; `SmalltalkImage>>#isHeadless`
  decides by scanning its own arguments for exactly that token, so with that VM
  the IDE can never open and no flag changes it. `--interactive` in particular
  does **not** work: the VM forwards it to the image but leaves `--headless`
  beside it, so the image stays headless, opens nothing, logs nothing, and idles
  forever — the stack shows only `ProcessorScheduler class>>idleProcess`. The VM
  comes from the `pharo-spur64` build instead, in the `pharo-vm` stage, and runs
  headless too when handed `--headless` explicitly.
- That VM is **deliberately not pinned**, unlike everything else here. `PHARO_VM_URL`
  points at `stable12.zip`, a moving pointer updated on each stable 12.x release,
  so the VM follows its stable line. The consequence is that the stage is not
  reproducible: two builds of the same commit can fetch different VMs, and a
  rebuild is the moment VM behaviour can change underneath the repository. Docker
  caches the layer, so an existing image keeps its VM until that stage is rebuilt
  without cache. Pass `PHARO_VM_URL` a
  `PharoVM-<version>-Linux-x86_64-stockReplacement-bin.zip` URL from the same
  directory to freeze it. The Pharo *image* version is a separate pin, the ba-st
  tag above, and the two move independently.
- The container has no `/dev/dri`, so Mesa cannot create a DRI3 screen and
  window creation fails outright — `MESA: error: Failed to query drm device`,
  `glx: failed to create dri3 screen`, then no window and no further complaint.
  `pharo-ui` therefore sets `LIBGL_ALWAYS_SOFTWARE=1`, and `libgl1-mesa-dri` is
  installed for the rasteriser behind it.
- Bumping that tag is **not enough on its own**. `create-pharo-image.sh` refuses
  to touch an existing working image, precisely so a rebuild never eats
  uncommitted work, and it is what `postCreateCommand` runs. After a Pharo
  version bump, `create-pharo-image.sh --force` is what actually adopts it.
- `pharo/` holds the working image and is gitignored, so it is not
  reproducible from the repository and is deliberately not meant to be:
  everything of value belongs in `source` through Iceberg.
- Iceberg clones every Metacello dependency, and the pristine image is built
  with `shareRepositoriesBetweenImages: true` so the clones land in
  `/home/node/iceberg` — a named volume — instead of beside the image. That is
  what makes them survive a rebuild, a fresh working image, and a `git clean
  -xdf`, and what stops a second image re-cloning the tree. The setting is a
  class variable baked into the pristine image at build time, so an image from
  anywhere else will not have it; `pharo eval "IceLibgitRepository
  repositoriesLocation fullName"` says which an image is using. Nothing stops
  two images writing one clone at once, which is Iceberg's own caveat for
  shared mode, not something this setup adds.
- `ICEBERG_REPOSITORIES_DIR` in `.devcontainer/.env` swaps that volume for a
  host directory, using the same interpolation trick as `REFERENCE_PROJECTS_DIR`:
  a bare name in a compose source position is a named volume, an absolute path
  is a bind mount, so `${ICEBERG_REPOSITORIES_DIR:-ba-st-iceberg}` is one or
  the other depending on whether it is set. A **relative** path would be read as
  neither — `../x` binds, but a bare `x` silently creates a volume called `x` —
  so it has to be absolute. The directory must exist on the host beforehand:
  Docker creates a missing bind source as root, and Iceberg's report of an
  unwritable directory is `PrimitiveFailed: primitive #createDirectory: in
  UnixStore failed`, naming neither path nor reason.
  `check-iceberg-repositories.sh` runs from `postCreateCommand` to catch that,
  and warns without failing, so it never blocks container creation.
- Dependency clones carry **SSH** remotes (`git@github.com:...`), so fetching
  them relies on VS Code forwarding the SSH agent — `SSH_AUTH_SOCK` and
  `ssh-add -l`. It works here, which is why the remotes are left alone rather
  than rewritten to HTTPS the way ba-st's loader image does; but a context
  without an agent, CI for instance, would need that rewrite.
- Nothing stops two VMs opening the same image, and two of them writing one
  `.changes` file corrupts it. `ps -eo args | grep vm/lib/pharo` is the check —
  note the real process is `/opt/pharo/vm/lib/pharo`, not `vm/pharo`, so a
  pattern matching the latter finds nothing and looks like the IDE died.
- The IDE needs two things that reduce isolation and are there on purpose:
  `/tmp/.X11-unix` bind-mounted, and `ipc: host` so SDL's MIT-SHM path works
  across the container boundary.
- `DISPLAY` is passed through from the host shell and deliberately **not**
  defaulted. Guessing `:0` is worse than leaving it empty: on a Plasma Wayland
  session the session's own XWayland server is `:1`, while `:0` belongs to
  something else and refuses the connection outright. `xhost` turned out to be
  unnecessary — the X server already admits the container's uid 1000 — so it
  belongs in troubleshooting, not in the setup steps.
