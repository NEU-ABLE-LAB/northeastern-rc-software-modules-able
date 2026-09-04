#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p short
#SBATCH --output=./logs/install_opencode_%j.out
#SBATCH --error=./logs/install_opencode_%j.err
#SBATCH --time=00:30:00

set -euo pipefail

SOFTWARE_NAME="opencode"
SOFTWARE_VERSION="1.18.23"
SOFTWARE_ARCH="linux-x64"

GROUP_DIRECTORY="/projects/able"

SOFTWARE_DIRECTORY="$GROUP_DIRECTORY/software/$SOFTWARE_NAME/$SOFTWARE_VERSION"
SOFTWARE_PACKAGE_DIRECTORY="$SOFTWARE_DIRECTORY/package"
SOFTWARE_DOWNLOADS_DIRECTORY="$SOFTWARE_DIRECTORY/downloads"

MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$SOFTWARE_NAME"

mkdir -p "$SOFTWARE_DOWNLOADS_DIRECTORY"
cd "$SOFTWARE_DOWNLOADS_DIRECTORY"

TARBALL="opencode-${SOFTWARE_ARCH}.tar.gz"

if [[ ! -f "$TARBALL" ]]; then
    wget         "https://github.com/anomalyco/opencode/releases/download/v${SOFTWARE_VERSION}/${TARBALL}"         -O "$TARBALL"
fi

rm -rf "$SOFTWARE_PACKAGE_DIRECTORY"
mkdir -p "$SOFTWARE_PACKAGE_DIRECTORY"

tar -xzf "$TARBALL" -C "$SOFTWARE_PACKAGE_DIRECTORY"

chmod +x "$SOFTWARE_PACKAGE_DIRECTORY/opencode"
chmod -R g+rX,o-rwx "$SOFTWARE_DIRECTORY"

mkdir -p "$MODULEFILE_DIRECTORY"

cat > "$MODULEFILE_DIRECTORY/$SOFTWARE_VERSION" <<EOF
#%Module
module-whatis "OpenCode $SOFTWARE_VERSION"

conflict opencode

prepend-path PATH $SOFTWARE_PACKAGE_DIRECTORY
EOF
