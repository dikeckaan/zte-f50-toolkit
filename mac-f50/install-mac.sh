#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
command -v brew >/dev/null || { echo "Homebrew gerekli: https://brew.sh" >&2; exit 1; }
brew list libusb >/dev/null 2>&1 || brew install libusb
BREW_PREFIX="$(brew --prefix)"
if [[ "$(uname -m)" == arm64 && -x "$ROOT/bin/spd_dump-arm64" ]]; then
  cp "$ROOT/bin/spd_dump-arm64" "$ROOT/bin/spd_dump"
else
  command -v make >/dev/null || { echo "Xcode Command Line Tools gerekli" >&2; exit 1; }
  make -C "$ROOT/w_spd_dump" clean all \
    CFLAGS="-O2 -Wall -std=c99 -DUSE_LIBUSB=1 -I$BREW_PREFIX/include/libusb-1.0" \
    LIBS="-L$BREW_PREFIX/lib -lusb-1.0 -lm -lpthread"
  cp "$ROOT/w_spd_dump/spd_dump" "$ROOT/bin/spd_dump"
fi
chmod +x "$ROOT/bin/spd_dump" "$ROOT"/*.sh
echo "Kurulum tamamlandı: $ROOT/bin/spd_dump"
"$ROOT/bin/spd_dump" --help | sed -n '1,8p'
