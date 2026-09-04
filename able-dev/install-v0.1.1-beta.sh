#!/bin/bash
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -p short
#SBATCH --output=./logs/install_able-dev_%j.out
#SBATCH --error=./logs/install_able-dev_%j.err
#SBATCH --time=03:00:00
set -euo pipefail

MODULE_NAME="able-dev"
MODULE_VERSION="0.1.1-beta"
CODE_SERVER_VERSION="4.135.0"
GH_VERSION="2.100.0"
OPENCODE_VERSION="1.18.28"
CODEX_VERSION="0.153.3"
CLAUDE_CODE_VERSION="2.1.260"

GROUP_DIRECTORY="/projects/able"
MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$MODULE_NAME"

# Slurm executes a copied script under /var/spool/slurmd. Submit from the
# repository root and use SLURM_SUBMIT_DIR rather than BASH_SOURCE.
REPO_ROOT="${SLURM_SUBMIT_DIR:?SLURM_SUBMIT_DIR is not set}"
echo "[INFO] Repository root resolved to: $REPO_ROOT"

EXPECTED_ENTRYPOINT="$REPO_ROOT/able-dev/install-v${MODULE_VERSION}.sh"
[[ -f "$EXPECTED_ENTRYPOINT" ]] || {
    echo "[ERROR] Submit from the repository root:" >&2
    echo "        sbatch able-dev/install-v${MODULE_VERSION}.sh" >&2
    exit 1
}

echo "[INFO] Starting $MODULE_NAME/$MODULE_VERSION on $(hostname) at $(date)"

bash "$REPO_ROOT/code-server/install-v${CODE_SERVER_VERSION}.sh"
bash "$REPO_ROOT/gh/install-v${GH_VERSION}.sh"
bash "$REPO_ROOT/opencode/install-v${OPENCODE_VERSION}.sh"
bash "$REPO_ROOT/codex/install-v${CODEX_VERSION}.sh"
bash "$REPO_ROOT/claude-code/install-v${CLAUDE_CODE_VERSION}.sh"

for modulefile in \
    "$MODULEFILE_PREFIX/code-server/$CODE_SERVER_VERSION" \
    "$MODULEFILE_PREFIX/gh/$GH_VERSION" \
    "$MODULEFILE_PREFIX/opencode/$OPENCODE_VERSION" \
    "$MODULEFILE_PREFIX/codex/$CODEX_VERSION" \
    "$MODULEFILE_PREFIX/claude-code/$CLAUDE_CODE_VERSION"
do
    [[ -f "$modulefile" ]] || { echo "[ERROR] Missing modulefile: $modulefile" >&2; exit 1; }
done

mkdir -p "$MODULEFILE_DIRECTORY"
cat > "$MODULEFILE_DIRECTORY/$MODULE_VERSION" <<EOF
#%Module
module-whatis "ABLE development environment beta: code-server, GitHub CLI + gh-sub-issue, OpenCode, Codex CLI, and Claude Code"
conflict able-dev
module load code-server/$CODE_SERVER_VERSION
module load gh/$GH_VERSION
module load opencode/$OPENCODE_VERSION
module load codex/$CODEX_VERSION
module load claude-code/$CLAUDE_CODE_VERSION
setenv ABLE_DEV_VERSION "$MODULE_VERSION"
EOF

echo "[SUCCESS] $MODULE_NAME/$MODULE_VERSION installed at $(date)"
echo "module use $MODULEFILE_PREFIX"
echo "module load $MODULE_NAME/$MODULE_VERSION"
