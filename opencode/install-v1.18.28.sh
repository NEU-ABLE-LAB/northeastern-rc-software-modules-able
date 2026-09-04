#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p short
#SBATCH --output=./logs/install_opencode_%j.out
#SBATCH --error=./logs/install_opencode_%j.err
#SBATCH --time=00:30:00
set -euo pipefail

SOFTWARE_NAME="opencode"
SOFTWARE_VERSION="1.18.28"
SOFTWARE_ARCH="linux-x64"
EXPECTED_SHA256="42add0fb1f13bdfd13855adc11cdaf2944c149377a873732168cdfd234fec7c3"

GROUP_DIRECTORY="/projects/able"
SOFTWARE_DIRECTORY="$GROUP_DIRECTORY/software/$SOFTWARE_NAME/$SOFTWARE_VERSION"
SOFTWARE_PACKAGE_DIRECTORY="$SOFTWARE_DIRECTORY/package"
SOFTWARE_DOWNLOADS_DIRECTORY="$SOFTWARE_DIRECTORY/downloads"
EXTRACT_DIRECTORY="$SOFTWARE_DIRECTORY/extract"
MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$SOFTWARE_NAME"
TARBALL="opencode-${SOFTWARE_ARCH}.tar.gz"

mkdir -p "$SOFTWARE_DOWNLOADS_DIRECTORY"
cd "$SOFTWARE_DOWNLOADS_DIRECTORY"
if [[ ! -f "$TARBALL" ]]; then
    wget "https://github.com/anomalyco/opencode/releases/download/v${SOFTWARE_VERSION}/${TARBALL}" -O "$TARBALL"
fi
echo "${EXPECTED_SHA256}  ${TARBALL}" | sha256sum -c -

rm -rf "$EXTRACT_DIRECTORY" "$SOFTWARE_PACKAGE_DIRECTORY"
mkdir -p "$EXTRACT_DIRECTORY" "$SOFTWARE_PACKAGE_DIRECTORY"
tar -xzf "$TARBALL" -C "$EXTRACT_DIRECTORY"

OPENCODE_BINARY="$(find "$EXTRACT_DIRECTORY" -type f -name opencode -print -quit)"
[[ -n "$OPENCODE_BINARY" ]] || { echo "[ERROR] OpenCode executable not found" >&2; exit 1; }
install -m 0755 "$OPENCODE_BINARY" "$SOFTWARE_PACKAGE_DIRECTORY/opencode"
rm -rf "$EXTRACT_DIRECTORY"

chmod -R g+rX,o-rwx "$SOFTWARE_DIRECTORY"
mkdir -p "$MODULEFILE_DIRECTORY"
cat > "$MODULEFILE_DIRECTORY/$SOFTWARE_VERSION" <<EOF
#%Module
module-whatis "OpenCode $SOFTWARE_VERSION"
conflict opencode
prepend-path PATH $SOFTWARE_PACKAGE_DIRECTORY
EOF
echo "[SUCCESS] Installed opencode/$SOFTWARE_VERSION"
