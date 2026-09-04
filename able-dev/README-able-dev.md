# able-dev module stack

**Release:** `0.1-beta` — initial beta release.

`able-dev/0.1-beta` provides a shared development environment for the ABLE HPC system.

It includes:

- `code-server/4.134.0`
- `gh/2.98.0`
  - GitHub CLI extension: `yahsan2/gh-sub-issue`
- `opencode/1.18.23`
- `codex/0.150.0`
- `claude-code/2.1.246`

## Install

`able-dev` has a single Slurm installation entrypoint.

From the repository root:

```bash
mkdir -p logs
sbatch able-dev/install-v0.1-beta.sh
```

You do **not** need to submit each component installer separately.

The top-level installer consumes the existing versioned install scripts in sequence:

```text
able-dev/install-v0.1-beta.sh
│
├── code-server/install-v4.134.0.sh
├── gh/install-v2.98.0.sh
├── opencode/install-v1.18.23.sh
├── codex/install-v0.150.0.sh
└── claude-code/install-v2.1.246.sh
        │
        ▼
creates /projects/able/modulefiles/able-dev/0.1-beta
```

Internally, the equivalent operations are:

```bash
bash code-server/install-v4.134.0.sh
bash gh/install-v2.98.0.sh
bash opencode/install-v1.18.23.sh
bash codex/install-v0.150.0.sh
bash claude-code/install-v2.1.246.sh
```

The component scripts remain separate so an individual tool can still be installed or upgraded independently when needed.

Because the component scripts are invoked with `bash`, their embedded `#SBATCH` directives are ignored during a full `able-dev` installation. The Slurm resources for the full installation come from `able-dev/install-v0.1-beta.sh`.

The installer uses `set -euo pipefail`, so a failure in any component stops the installation before the `able-dev` meta-module is created.

## Use

After the installation job completes successfully:

```bash
module use /projects/able/modulefiles
module load able-dev/0.1-beta
```

This loads:

```text
code-server/4.134.0
gh/2.98.0
opencode/1.18.23
codex/0.150.0
claude-code/2.1.246
```

## GitHub CLI extension

The `gh` environment includes:

```text
yahsan2/gh-sub-issue
```

GitHub CLI extensions are user-scoped. On first use, the `gh` wrapper checks whether `sub-issue` is available for the current user and installs it when required:

```bash
gh extension install yahsan2/gh-sub-issue
```

This keeps GitHub authentication and extension state associated with each user while the main `gh` executable remains shared.

## Check

```bash
module list

code-server --version
gh --version
gh extension list
gh sub-issue --help
opencode --version
codex --version
claude --version

echo "$ABLE_DEV_VERSION"
```

Expected module stack:

```text
able-dev/0.1-beta
code-server/4.134.0
gh/2.98.0
opencode/1.18.23
codex/0.150.0
claude-code/2.1.246
```

## Install an individual component

The versioned installers can still be submitted independently. For example:

```bash
sbatch gh/install-v2.98.0.sh
```

This is useful when updating or repairing one tool without reinstalling the full `able-dev` environment.

## Authentication

Authentication is per user.

Do not put GitHub, OpenAI, Anthropic, or other API tokens in shared modulefiles. Each user should authenticate or configure credentials in their own account after loading the module.

## No sudo

The installers do not use `sudo` or require a system package installation.

Software is installed under:

```text
/projects/able/software/
```

Modulefiles are installed under:

```text
/projects/able/modulefiles/
```

The user running the installation must have write access to these directories.
