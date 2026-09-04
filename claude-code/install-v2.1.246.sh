#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p short
#SBATCH --output=./logs/install_claude-code_%j.out
#SBATCH --error=./logs/install_claude-code_%j.err
#SBATCH --time=00:30:00

set -euo pipefail

SOFTWARE_NAME="claude-code"
SOFTWARE_VERSION="2.1.246"
SOFTWARE_ARCH="linux-x64"
GROUP_DIRECTORY="/projects/able"
SOFTWARE_DIRECTORY="$GROUP_DIRECTORY/software/$SOFTWARE_NAME/$SOFTWARE_VERSION"
SOFTWARE_PACKAGE_DIRECTORY="$SOFTWARE_DIRECTORY/package"
SOFTWARE_DOWNLOADS_DIRECTORY="$SOFTWARE_DIRECTORY/downloads"
EXTRACT_DIRECTORY="$SOFTWARE_DIRECTORY/extract"
MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$SOFTWARE_NAME"
TARBALL="claude-${SOFTWARE_ARCH}.tar.gz"

mkdir -p "$SOFTWARE_DOWNLOADS_DIRECTORY"
cd "$SOFTWARE_DOWNLOADS_DIRECTORY"

if [[ ! -f "$TARBALL" ]]; then
  wget "https://github.com/anthropics/claude-code/releases/download/v${SOFTWARE_VERSION}/${TARBALL}" -O "$TARBALL"
fi

rm -rf "$EXTRACT_DIRECTORY" "$SOFTWARE_PACKAGE_DIRECTORY"
mkdir -p "$EXTRACT_DIRECTORY" "$SOFTWARE_PACKAGE_DIRECTORY"
tar -xzf "$TARBALL" -C "$EXTRACT_DIRECTORY"
CLAUDE_BINARY="$(find "$EXTRACT_DIRECTORY" -type f -name 'claude' -print -quit)"
[[ -n "$CLAUDE_BINARY" ]] || { echo "[ERROR] Claude executable not found" >&2; exit 1; }
install -m 0755 "$CLAUDE_BINARY" "$SOFTWARE_PACKAGE_DIRECTORY/claude"
rm -rf "$EXTRACT_DIRECTORY"
chmod -R g+rX,o-rwx "$SOFTWARE_DIRECTORY"

mkdir -p "$MODULEFILE_DIRECTORY"
cat > "$MODULEFILE_DIRECTORY/$SOFTWARE_VERSION" <<EOF_MODULE
#%Module
module-whatis "Claude Code CLI $SOFTWARE_VERSION"
conflict claude-code
prepend-path PATH $SOFTWARE_PACKAGE_DIRECTORY
EOF_MODULE

echo "[SUCCESS] Installed claude-code/$SOFTWARE_VERSION"
