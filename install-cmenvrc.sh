#!/usr/bin/env bash
set -euo pipefail

# cmenvrc installer
# Usage:
#   curl -sSfL https://raw.githubusercontent.com/stephencheng/cmutils/main/install-cmenvrc.sh | bash
#
# Options (via env vars):
#   VERSION=v0.1.0              Install a specific version (default: latest)
#   INSTALL_DIR=/usr/local/bin  Install location (default: /usr/local/bin)

REPO="stephencheng/cmutils"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
BINARY="cmenvrc"

info()  { echo "  $*"; }
error() { echo "ERROR: $*" >&2; exit 1; }

detect_platform() {
  local os arch

  case "$(uname -s)" in
    Linux*)  os=linux ;;
    Darwin*) os=darwin ;;
    MINGW*|MSYS*|CYGWIN*) os=windows ;;
    *) error "Unsupported OS: $(uname -s)" ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64)  arch=amd64 ;;
    arm64|aarch64) arch=arm64 ;;
    *) error "Unsupported architecture: $(uname -m)" ;;
  esac

  # macOS Intel: use arm64 binary via Rosetta 2
  if [[ "$os" == "darwin" && "$arch" == "amd64" ]]; then
    info "macOS Intel detected — using arm64 binary (runs via Rosetta 2)"
    arch=arm64
  fi

  PLATFORM="${os}-${arch}"

  if [[ "$os" == "windows" ]]; then
    ASSET="${BINARY}-${PLATFORM}.exe"
  else
    ASSET="${BINARY}-${PLATFORM}"
  fi
}

detect_version() {
  if [[ -n "${VERSION:-}" ]]; then
    return
  fi

  info "Detecting latest version..."

  VERSION=$(curl -sSf "https://api.github.com/repos/${REPO}/releases" 2>/dev/null \
    | grep -o '"tag_name": *"cmenvrc-v[^"]*"' \
    | head -1 \
    | sed 's/.*"cmenvrc-\(v[^"]*\)".*/\1/' || true)

  if [[ -z "$VERSION" ]]; then
    error "Could not detect latest version. Set VERSION=v0.1.0 manually."
  fi
}

download() {
  local url tmpdir tmpfile

  local tag="cmenvrc-${VERSION}"
  url="https://github.com/${REPO}/releases/download/${tag}/${ASSET}"

  info "Downloading: ${url}"
  tmpdir=$(mktemp -d)
  tmpfile="${tmpdir}/${BINARY}"

  if ! curl -sSfL -o "$tmpfile" "$url"; then
    rm -rf "$tmpdir"
    error "Download failed. Check that ${VERSION} exists and has a ${PLATFORM} build."
  fi

  chmod +x "$tmpfile"
  TMPFILE="$tmpfile"
  TMPDIR="$tmpdir"
}

install_binary() {
  info "Installing to ${INSTALL_DIR}/${BINARY}..."

  if [[ -w "$INSTALL_DIR" ]]; then
    mv "$TMPFILE" "${INSTALL_DIR}/${BINARY}"
  else
    info "(requires sudo)"
    sudo mv "$TMPFILE" "${INSTALL_DIR}/${BINARY}"
  fi

  rm -rf "$TMPDIR"
}

verify() {
  if ! command -v "$BINARY" &>/dev/null; then
    info ""
    info "Installed to ${INSTALL_DIR}/${BINARY} but it's not in PATH."
    info "Add this to your shell profile:"
    info "  export PATH=\"${INSTALL_DIR}:\$PATH\""
    return
  fi

  local installed_version
  installed_version=$("$BINARY" --version 2>&1 || true)
  info "Installed: ${installed_version}"
}

main() {
  echo ""
  echo "cmenvrc installer"
  echo "================="
  echo ""

  detect_platform
  info "Platform: ${PLATFORM}"

  detect_version
  info "Version:  ${VERSION}"
  echo ""

  download
  install_binary
  echo ""

  verify

  echo ""
  info "Done! Get started:"
  info "  cmenvrc login          # set up access token + org ID"
  info "  cmenvrc migrate .envrc # migrate existing secrets"
  info "  cmenvrc --help         # see all commands"
  echo ""
}

main
