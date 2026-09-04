#!/bin/bash
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -p short
#SBATCH --output=./logs/install_code-server_%j.out
#SBATCH --error=./logs/install_code-server_%j.err
#SBATCH --time=01:00:00
set -euo pipefail

SOFTWARE_NAME="code-server"
SOFTWARE_VERSION="4.135.0"
SOFTWARE_ARCH="linux-amd64"
EXPECTED_SHA256="300ef4e37e469e6368a4673c6a623e1c9ba8a34f42b394fb49c431a8900bc7d1"

GROUP_DIRECTORY="/projects/able"
SOFTWARE_DIRECTORY="$GROUP_DIRECTORY/software/$SOFTWARE_NAME/$SOFTWARE_VERSION"
SOFTWARE_PACKAGE_DIRECTORY="$SOFTWARE_DIRECTORY/code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}"
SOFTWARE_DOWNLOADS_DIRECTORY="$SOFTWARE_DIRECTORY/downloads"
MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$SOFTWARE_NAME"

TARBALL="code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}.tar.gz"
EXTRACTED_DIRECTORY="code-server-${SOFTWARE_VERSION}-${SOFTWARE_ARCH}"

mkdir -p "$SOFTWARE_DOWNLOADS_DIRECTORY"
cd "$SOFTWARE_DOWNLOADS_DIRECTORY"
if [[ ! -f "$TARBALL" ]]; then
    wget "https://github.com/coder/code-server/releases/download/v${SOFTWARE_VERSION}/${TARBALL}" -O "$TARBALL"
fi
echo "${EXPECTED_SHA256}  ${TARBALL}" | sha256sum -c -

rm -rf "$EXTRACTED_DIRECTORY"
tar -xzf "$TARBALL"
rm -rf "$SOFTWARE_PACKAGE_DIRECTORY"
mv "$EXTRACTED_DIRECTORY" "$SOFTWARE_PACKAGE_DIRECTORY"

chmod -R g+rX,o-rwx "$SOFTWARE_DIRECTORY"
mkdir -p "$MODULEFILE_DIRECTORY"
cat > "$MODULEFILE_DIRECTORY/$SOFTWARE_VERSION" <<EOF
#%Module
module-whatis "Code Server $SOFTWARE_VERSION"
conflict code-server
prepend-path PATH            $SOFTWARE_PACKAGE_DIRECTORY/bin
prepend-path LD_LIBRARY_PATH $SOFTWARE_PACKAGE_DIRECTORY/lib
prepend-path LIBRARY_PATH    $SOFTWARE_PACKAGE_DIRECTORY/lib
set-alias code "code-server -r "
setenv EXTENSIONS_GALLERY "{\"serviceUrl\": \"https://marketplace.visualstudio.com/_apis/public/gallery\"}"
EOF
echo "[SUCCESS] Installed code-server/$SOFTWARE_VERSION"
