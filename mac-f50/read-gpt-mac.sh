#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SPD="$ROOT/bin/spd_dump"
[[ -x "$SPD" ]] || { echo "Önce ./install-mac.sh çalıştır" >&2; exit 1; }
OUT="${1:-$ROOT/gpt.xml}"
exec "$SPD" --wait 300 --verbose 1 --kickto 2 path "$ROOT" partition_list "$OUT"
