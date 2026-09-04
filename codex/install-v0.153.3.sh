#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p short
#SBATCH --output=./logs/install_codex_%j.out
#SBATCH --error=./logs/install_codex_%j.err
#SBATCH --time=00:30:00
set -euo pipefail

SOFTWARE_NAME="codex"
SOFTWARE_VERSION="0.153.3"
RELEASE_TAG="rust-v${SOFTWARE_VERSION}"
SOFTWARE_ARCH="x86_64-unknown-linux-musl"
EXPECTED_SHA256="47bb1fb36fb1dbd5fe1af3eb0db422ffb4c3c38d9c1762c7618a9bed46c44a63"

GROUP_DIRECTORY="/projects/able"
SOFTWARE_DIRECTORY="$GROUP_DIRECTORY/software/$SOFTWARE_NAME/$SOFTWARE_VERSION"
SOFTWARE_PACKAGE_DIRECTORY="$SOFTWARE_DIRECTORY/package"
SOFTWARE_DOWNLOADS_DIRECTORY="$SOFTWARE_DIRECTORY/downloads"
EXTRACT_DIRECTORY="$SOFTWARE_DIRECTORY/extract"
MODULEFILE_PREFIX="$GROUP_DIRECTORY/modulefiles"
MODULEFILE_DIRECTORY="$MODULEFILE_PREFIX/$SOFTWARE_NAME"

TARBALL="codex-package-${SOFTWARE_ARCH}.tar.gz"

mkdir -p "$SOFTWARE_DOWNLOADS_DIRECTORY"
cd "$SOFTWARE_DOWNLOADS_DIRECTORY"
if [[ ! -f "$TARBALL" ]]; then
    wget "https://github.com/openai/codex/releases/download/${RELEASE_TAG}/${TARBALL}" -O "$TARBALL"
fi
echo "${EXPECTED_SHA256}  ${TARBALL}" | sha256sum -c -

rm -rf "$EXTRACT_DIRECTORY" "$SOFTWARE_PACKAGE_DIRECTORY"
mkdir -p "$EXTRACT_DIRECTORY" "$SOFTWARE_PACKAGE_DIRECTORY"
tar -xzf "$TARBALL" -C "$EXTRACT_DIRECTORY"

shopt -s dotglob nullglob
entries=("$EXTRACT_DIRECTORY"/*)
if (( ${#entries[@]} == 1 )) && [[ -d "${entries[0]}" ]]; then
    cp -a "${entries[0]}/." "$SOFTWARE_PACKAGE_DIRECTORY/"
else
    cp -a "$EXTRACT_DIRECTORY/." "$SOFTWARE_PACKAGE_DIRECTORY/"
fi
shopt -u dotglob nullglob
rm -rf "$EXTRACT_DIRECTORY"

CODEX_BINARY="$(find "$SOFTWARE_PACKAGE_DIRECTORY" -type f -name codex -print -quit)"
CODE_MODE_HOST="$(find "$SOFTWARE_PACKAGE_DIRECTORY" -type f -name codex-code-mode-host -print -quit)"
[[ -n "$CODEX_BINARY" && -x "$CODEX_BINARY" ]] || { echo "[ERROR] codex executable not found" >&2; exit 1; }
[[ -n "$CODE_MODE_HOST" && -x "$CODE_MODE_HOST" ]] || { echo "[ERROR] codex-code-mode-host not found" >&2; exit 1; }

CODEX_BIN_DIRECTORY="$(dirname "$CODEX_BINARY")"
if [[ "$(dirname "$CODE_MODE_HOST")" != "$CODEX_BIN_DIRECTORY" ]]; then
    echo "[ERROR] codex-code-mode-host is not next to codex" >&2
    echo "codex: $CODEX_BINARY" >&2
    echo "host:  $CODE_MODE_HOST" >&2
    exit 1
fi

chmod -R g+rX,o-rwx "$SOFTWARE_DIRECTORY"
mkdir -p "$MODULEFILE_DIRECTORY"
cat > "$MODULEFILE_DIRECTORY/$SOFTWARE_VERSION" <<EOF
#%Module
module-whatis "OpenAI Codex CLI $SOFTWARE_VERSION"
conflict codex
prepend-path PATH $CODEX_BIN_DIRECTORY
setenv CODEX_CODE_MODE_HOST_PATH "$CODE_MODE_HOST"
EOF

echo "[SUCCESS] Installed codex/$SOFTWARE_VERSION"
echo "[INFO] Codex binary: $CODEX_BINARY"
echo "[INFO] Code Mode host: $CODE_MODE_HOST"
