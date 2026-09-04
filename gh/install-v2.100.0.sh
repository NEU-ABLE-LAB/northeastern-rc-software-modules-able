#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p short
#SBATCH --output=./logs/install_gh_%j.out
#SBATCH --error=./logs/install_gh_%j.err
#SBATCH --time=00:30:00
set -euo pipefail

SOFTWARE_NAME="gh"
SOFTWARE_VERSION="2.100.0"
SOFTWARE_ARCH="linux_amd64"
EXPECTED_SHA256="e4d4bb4498e8d007abe545b6568926793ace1b6447da598294a610018cb164be"

GROUP_DIRECTORY="/projects/able"
SOFTWARE_DIRECTORY="$GROUP_DIRECTORY/software/$SOFTWARE_NAME/$SOFTWARE_VERSION"
SOFTWARE_PACKAGE_DIRECTORY="$SOFTWARE_DIRECTORY/gh_${SOFTWARE_VERSION}_${SOFTWARE_ARCH}"
SOFTWARE_DOWNLOADS_DIRECTORY="$SOFTWARE_DIRECTORY/downloads"
WRAPPER_DIRECTORY="$SOFTWARE_DIRECTORY/wrapper-bin"
MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$SOFTWARE_NAME"

TARBALL="gh_${SOFTWARE_VERSION}_${SOFTWARE_ARCH}.tar.gz"
EXTRACTED_DIRECTORY="gh_${SOFTWARE_VERSION}_${SOFTWARE_ARCH}"

mkdir -p "$SOFTWARE_DOWNLOADS_DIRECTORY"
cd "$SOFTWARE_DOWNLOADS_DIRECTORY"
if [[ ! -f "$TARBALL" ]]; then
    wget "https://github.com/cli/cli/releases/download/v${SOFTWARE_VERSION}/${TARBALL}" -O "$TARBALL"
fi
echo "${EXPECTED_SHA256}  ${TARBALL}" | sha256sum -c -

rm -rf "$EXTRACTED_DIRECTORY"
tar -xzf "$TARBALL"
rm -rf "$SOFTWARE_PACKAGE_DIRECTORY"
mv "$EXTRACTED_DIRECTORY" "$SOFTWARE_PACKAGE_DIRECTORY"

REAL_GH="$SOFTWARE_PACKAGE_DIRECTORY/bin/gh"
[[ -x "$REAL_GH" ]] || { echo "[ERROR] gh executable not found: $REAL_GH" >&2; exit 1; }

mkdir -p "$WRAPPER_DIRECTORY"
cat > "$WRAPPER_DIRECTORY/gh" <<EOF
#!/bin/bash
set -euo pipefail
REAL_GH="$REAL_GH"
if [[ "\${ABLE_GH_SKIP_EXTENSION_BOOTSTRAP:-0}" != "1" ]]; then
    if ! "\$REAL_GH" extension list 2>/dev/null | grep -q 'yahsan2/gh-sub-issue'; then
        echo "[INFO] Installing yahsan2/gh-sub-issue for \${USER:-current user}..." >&2
        "\$REAL_GH" extension install yahsan2/gh-sub-issue || \
            echo "[WARN] Could not install yahsan2/gh-sub-issue; continuing." >&2
    fi
fi
exec "\$REAL_GH" "\$@"
EOF
chmod 0755 "$WRAPPER_DIRECTORY/gh"

chmod -R g+rX,o-rwx "$SOFTWARE_DIRECTORY"
mkdir -p "$MODULEFILE_DIRECTORY"
cat > "$MODULEFILE_DIRECTORY/$SOFTWARE_VERSION" <<EOF
#%Module
module-whatis "GitHub CLI $SOFTWARE_VERSION with per-user yahsan2/gh-sub-issue bootstrap"
conflict gh
prepend-path PATH $SOFTWARE_PACKAGE_DIRECTORY/bin
prepend-path PATH $WRAPPER_DIRECTORY
EOF
echo "[SUCCESS] Installed gh/$SOFTWARE_VERSION"
