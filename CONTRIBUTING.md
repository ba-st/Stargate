# Contributing

There are several ways to contribute to the project: reporting bugs, sending
feedback, proposing ideas for new features, fixing or adding documentation,
promoting the project, or even contributing code.

## Reporting issues

You can report issues by [opening a new GitHub issue](https://github.com/ba-st/Stargate/issues/new).

## Branching and Releases

The `release-candidate` branch is the production branch. All changes must reach it through a pull request — direct pushes are not allowed.

### Feature Branch Naming

Branches must follow the pattern `{category}/{issue-id}-{slug}`, where:

- **category** is one of: `feature`, `bugfix`, `docs`, `chore`, `refactor`
- **issue-id** is the GitHub issue number. It is required whenever the work has an associated issue, and omitted otherwise, leaving the pattern `{category}/{slug}`
- **slug** is a short description in kebab-case

Examples: `feature/1234-user-login`, `bugfix/5678-fix-null-pointer`, `docs/91011-update-readme`

Without an issue: `chore/devcontainer-setup`, `refactor/extract-price-calculation`

### Commit Messages

Commit messages must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```text
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

The **type** maps directly to the branch category:

| Branch category | Commit type |
| --- | --- |
| `feature` | `feat` |
| `bugfix` | `fix` |
| `docs` | `docs` |
| `chore` | `chore` |
| `refactor` | `refactor` |

The **scope** is optional and should name the area of the codebase affected (e.g. `auth`, `api`, `ci`).

The **description** is a short, imperative-mood summary written in lowercase.

Examples:

```text
feat(auth): add OAuth2 login support
fix(api): handle null response from payment gateway
docs(contributing): add commit message conventions
chore(ci): update markdownlint action to v1
refactor(orders): extract price calculation into service
```

Breaking changes must be indicated by appending `!` after the type/scope, or by adding a `BREAKING CHANGE:` footer in the commit body:

```text
feat(api)!: remove deprecated v1 endpoints
```

### Pull Request Requirements

- PRs must be merged using the **squash** strategy to keep the branch history clean and linear.
- PR titles must comply with the conventional commits style

## Contributing Code

- This project is MIT licensed, so any code contribution MUST be under the same license.
- This project uses [Semantic Versioning](http://semver.org/), so keep it in
  mind when you make backwards-incompatible changes. If some backwards
  incompatible change is made the major version MUST be increased.
- The source code is hosted in this repository using the Tonel format in the
  `source` folder.
- Code contributions without test cases have a lower probability of being merged
  into the main branch.

## Feature Workflow

Every feature is planned before it is built, and built in phases that are each reviewed on their own.

### The Plan

Work on a feature starts with an implementation plan in `PLAN.md`, at the repository root. The file is gitignored: it is a working document, and the feature's GitHub issue is its durable copy.

The plan holds:

- **Scope** — what the feature delivers, and what it deliberately leaves out
- **Phases** — the phases for the feature's kind, each broken into concrete, executable tasks and ending in the checks that prove it done: which tests, which linters, which commands
- **Status** — for each phase, whether it is not started, in progress, in review or done, with its branch and pull request
- **Recaps** — one for each finished phase, described below
- **Open questions** — anything undecided, and the phase that has to settle it

Once the plan is approved, a feature issue is opened in GitHub mirroring it. There is one `PLAN.md` at a time.

### Phases of a Feature

| # | Phase | Delivers | Proven by |
| --- | --- | --- | --- |
| 1 | Model | The domain abstractions | Unit tests |
| 2 | Documentation | Revisions to `docs/`, and the architectural decisions worth keeping in writing | `markdownlint` |

The plan proposes them, and approving the plan approves them.

### Recaps

Consecutive phases may be carried out in different sessions, so the plan must hold everything the next one needs. Once a phase is reviewed and merged, `PLAN.md` gains its recap: what was delivered and in which pull request, where the work departed from the plan and why, what it left for later, and any change it forces on the phases still ahead. The feature issue is updated to match.

### Closing a Feature

After the last phase, a final review gathers every pending item, TODO and open question, from the plan, the recaps, the pull request reviews and the code itself. Each is resolved, or moved into an issue of its own, before the feature issue is closed.

## Documentation

The project documentation is maintained in this repository in the `docs`
folder and licensed under CC BY-SA 4.0, organized by content type:

| Folder | Purpose |
| --- | --- |
| `docs/how-to/` | Goal-oriented recipes for readers who already know what they want to achieve |
| `docs/reference/` | Reference material (APIs, configuration options, etc.) |
| `docs/tutorials/` | Learning-oriented walkthroughs for newcomers |
| `docs/explanation/` | Clarifications and in-depth discussions of concepts |

following the [Diátaxis](https://diataxis.fr/) documentation guidelines.

### Choosing a Folder

Diátaxis sorts documentation by the reader's situation rather than by subject. Two questions place almost any page:

- Is the reader **studying**, building understanding, or **working**, getting something done?
- Is the content **practical**, steps to follow, or **theoretical**, information to absorb?

| | Practical | Theoretical |
| --- | --- | --- |
| **Studying** | `docs/tutorials/` | `docs/explanation/` |
| **Working** | `docs/how-to/` | `docs/reference/` |

Tutorials and how-to guides are the pair most often confused:

- A **tutorial** walks a newcomer along a route *we* chose and guarantees a successful result. It offers no alternatives and does not digress to explain.
- A **how-to guide** serves a reader who already knows the goal and has the background to reach it. It may skip steps that are obvious to a practitioner.

Keep the four modes separate. A tutorial that keeps stopping to explain, or a how-to that swells into reference, serves neither reader well.

Markdown files must be linted using `markdownlint`.

## Shell Scripts

Shell scripts must be linted using `shellcheck`.
