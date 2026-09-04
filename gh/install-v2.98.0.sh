#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p short
#SBATCH --output=./logs/install_gh_%j.out
#SBATCH --error=./logs/install_gh_%j.err
#SBATCH --time=00:30:00

set -euo pipefail

SOFTWARE_NAME="gh"
SOFTWARE_VERSION="2.98.0"
SOFTWARE_ARCH="linux_amd64"
GH_SUB_ISSUE_REPOSITORY="yahsan2/gh-sub-issue"

GROUP_DIRECTORY="/projects/able"

SOFTWARE_DIRECTORY="$GROUP_DIRECTORY/software/$SOFTWARE_NAME/$SOFTWARE_VERSION"
SOFTWARE_PACKAGE_DIRECTORY="$SOFTWARE_DIRECTORY/gh_${SOFTWARE_VERSION}_${SOFTWARE_ARCH}"
SOFTWARE_DOWNLOADS_DIRECTORY="$SOFTWARE_DIRECTORY/downloads"
SOFTWARE_WRAPPER_DIRECTORY="$SOFTWARE_DIRECTORY/wrapper-bin"

MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$SOFTWARE_NAME"

mkdir -p "$SOFTWARE_DOWNLOADS_DIRECTORY"
cd "$SOFTWARE_DOWNLOADS_DIRECTORY"

TARBALL="gh_${SOFTWARE_VERSION}_${SOFTWARE_ARCH}.tar.gz"

if [[ ! -f "$TARBALL" ]]; then
    wget "https://github.com/cli/cli/releases/download/v${SOFTWARE_VERSION}/${TARBALL}"
fi

rm -rf "gh_${SOFTWARE_VERSION}_${SOFTWARE_ARCH}"
tar -xzf "$TARBALL"

rm -rf "$SOFTWARE_PACKAGE_DIRECTORY"
mv "gh_${SOFTWARE_VERSION}_${SOFTWARE_ARCH}" "$SOFTWARE_PACKAGE_DIRECTORY"

# gh extensions are user-scoped. Put a wrapper before the real gh binary so
# every able-dev user gets the bundled extension on first use without sudo.
mkdir -p "$SOFTWARE_WRAPPER_DIRECTORY"
cat > "$SOFTWARE_WRAPPER_DIRECTORY/gh" <<EOF_WRAPPER
#!/usr/bin/env bash
set -euo pipefail

REAL_GH="$SOFTWARE_PACKAGE_DIRECTORY/bin/gh"
EXTENSION_REPOSITORY="$GH_SUB_ISSUE_REPOSITORY"
EXTENSION_NAME="sub-issue"

if ! "\$REAL_GH" extension list 2>/dev/null | awk '{print \$1}' | grep -Fxq "\$EXTENSION_NAME"; then
    echo "[INFO] Installing bundled GitHub CLI extension: \$EXTENSION_REPOSITORY" >&2
    "\$REAL_GH" extension install "\$EXTENSION_REPOSITORY"
fi

exec "\$REAL_GH" "\$@"
EOF_WRAPPER
chmod 0755 "$SOFTWARE_WRAPPER_DIRECTORY/gh"

chmod -R g+rX,o-rwx "$SOFTWARE_DIRECTORY"

mkdir -p "$MODULEFILE_DIRECTORY"

cat > "$MODULEFILE_DIRECTORY/$SOFTWARE_VERSION" <<EOF_MODULE
#%Module
module-whatis "GitHub CLI $SOFTWARE_VERSION with gh-sub-issue"

conflict gh

prepend-path PATH $SOFTWARE_PACKAGE_DIRECTORY/bin
prepend-path PATH $SOFTWARE_WRAPPER_DIRECTORY
EOF_MODULE

echo "[SUCCESS] Installed gh/$SOFTWARE_VERSION with $GH_SUB_ISSUE_REPOSITORY"
