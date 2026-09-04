# able-dev

**Release:** `0.1.1-beta`

`able-dev/0.1-beta` provides a shared development environment for the ABLE HPC system.
## Included

| Tool | Version |
| --- | --- |
| code-server | `4.135.0` |
| GitHub CLI | `2.100.0` |
| yahsan2/gh-sub-issue | per-user `gh` extension |
| OpenCode | `1.18.28` |
| OpenAI Codex CLI | `0.153.3` |
| Claude Code | `2.1.260` |

## Install

`able-dev` has a single Slurm installation entrypoint.

From the repository root:

```bash
mkdir -p logs
sbatch able-dev/install-v0.1.1-beta.sh
```

The top-level installer consumes:

```text
able-dev/install-v0.1.1-beta.sh
|
├── code-server/install-v4.135.0.sh
├── gh/install-v2.100.0.sh
├── opencode/install-v1.18.28.sh
├── codex/install-v0.153.3.sh
└── claude-code/install-v2.1.260.sh
```

`SLURM_SUBMIT_DIR` is used for repository discovery because Slurm executes the
submitted batch script from a spool location such as `/var/spool/slurmd`.

Internally, the equivalent operations are:

```bash
bash code-server/install-v4.134.0.sh
bash gh/install-v2.98.0.sh
bash opencode/install-v1.18.23.sh
bash codex/install-v0.150.0.sh
bash claude-code/install-v2.1.246.sh
```
## Use

After the installation job completes successfully:

```bash
module use /projects/able/modulefiles
module load able-dev/0.1.1-beta
```

Verify:

```bash
code-server --version
gh --version
gh extension list
gh sub-issue --help
opencode --version
codex --version
claude --version
echo "$ABLE_DEV_VERSION"
```

## Codex Code Mode

Codex is installed from the complete:

```text
codex-package-x86_64-unknown-linux-musl.tar.gz
```

The package contents are preserved. Installation fails unless `codex` and
`codex-code-mode-host` both exist and are siblings. The modulefile also sets
`CODEX_CODE_MODE_HOST_PATH` explicitly.

## GitHub CLI extension

`yahsan2/gh-sub-issue` remains per-user. The shared `gh` wrapper checks for it
on first use and installs it into the user's own GitHub CLI extension location.

To bypass the bootstrap temporarily:

```bash
export ABLE_GH_SKIP_EXTENSION_BOOTSTRAP=1
```

## Authentication

Shared modulefiles contain binaries and environment configuration only. Do not
store GitHub, OpenAI, Anthropic, or other API tokens under `/projects/able`.

Each user authenticates in their own account/home directory.

## Locations

```text
/projects/able/software/
/projects/able/modulefiles/
```

The user running the installation must have write access to these directories.
