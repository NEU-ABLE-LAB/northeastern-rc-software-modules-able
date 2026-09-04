#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p short
#SBATCH --output=./logs/install_able-dev_%j.out
#SBATCH --error=./logs/install_able-dev_%j.err
#SBATCH --time=02:00:00

set -euo pipefail

MODULE_NAME="able-dev"
MODULE_VERSION="0.1-beta"

CODE_SERVER_VERSION="4.134.0"
GH_VERSION="2.98.0"
OPENCODE_VERSION="1.18.23"
CODEX_VERSION="0.150.0"
CLAUDE_CODE_VERSION="2.1.246"

GROUP_DIRECTORY="/projects/able"
MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$MODULE_NAME"

# Resolve the repository root regardless of the directory from which sbatch is run.
REPO_ROOT="${SLURM_SUBMIT_DIR:?SLURM_SUBMIT_DIR is not set}"

echo "[INFO] Repository root resolved to: $REPO_ROOT"

echo "[INFO] Starting $MODULE_NAME/$MODULE_VERSION installation on $(hostname) at $(date)"

echo "[STEP] Installing code-server/$CODE_SERVER_VERSION"
bash "$REPO_ROOT/code-server/install-v${CODE_SERVER_VERSION}.sh"

echo "[STEP] Installing gh/$GH_VERSION"
bash "$REPO_ROOT/gh/install-v${GH_VERSION}.sh"

echo "[STEP] Installing opencode/$OPENCODE_VERSION"
bash "$REPO_ROOT/opencode/install-v${OPENCODE_VERSION}.sh"

echo "[STEP] Installing codex/$CODEX_VERSION"
bash "$REPO_ROOT/codex/install-v${CODEX_VERSION}.sh"

echo "[STEP] Installing claude-code/$CLAUDE_CODE_VERSION"
bash "$REPO_ROOT/claude-code/install-v${CLAUDE_CODE_VERSION}.sh"

echo "[STEP] Verifying required modulefiles"
for modulefile in \
    "$MODULEFILE_PREFIX/code-server/$CODE_SERVER_VERSION" \
    "$MODULEFILE_PREFIX/gh/$GH_VERSION" \
    "$MODULEFILE_PREFIX/opencode/$OPENCODE_VERSION" \
    "$MODULEFILE_PREFIX/codex/$CODEX_VERSION" \
    "$MODULEFILE_PREFIX/claude-code/$CLAUDE_CODE_VERSION"
do
    if [[ ! -f "$modulefile" ]]; then
        echo "[ERROR] Required modulefile not found: $modulefile" >&2
        exit 1
    fi
done

echo "[STEP] Creating $MODULE_NAME/$MODULE_VERSION meta-module"
mkdir -p "$MODULEFILE_DIRECTORY"

cat > "$MODULEFILE_DIRECTORY/$MODULE_VERSION" <<EOF_MODULE
#%Module
module-whatis "ABLE development environment beta release: code-server, GitHub CLI + gh-sub-issue, OpenCode, Codex CLI, and Claude Code"

conflict able-dev

module load code-server/$CODE_SERVER_VERSION
module load gh/$GH_VERSION
module load opencode/$OPENCODE_VERSION
module load codex/$CODEX_VERSION
module load claude-code/$CLAUDE_CODE_VERSION

setenv ABLE_DEV_VERSION "$MODULE_VERSION"
EOF_MODULE

echo "[SUCCESS] $MODULE_NAME/$MODULE_VERSION installation completed at $(date)"
echo
echo "Use:"
echo "  module use $MODULEFILE_PREFIX"
echo "  module load $MODULE_NAME/$MODULE_VERSION"
