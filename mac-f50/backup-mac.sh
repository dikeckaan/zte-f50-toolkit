#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SPD="$ROOT/bin/spd_dump"
[[ -x "$SPD" ]] || { echo "Önce ./install-mac.sh çalıştır" >&2; exit 1; }
STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
OUT="$ROOT/../backups/mac_$STAMP"
mkdir -p "$OUT"
echo "Tam lite yedek alınacak; userdata/cache/blackbox hariç tutulur."
exec "$SPD" --wait 300 --verbose 1 --kickto 2 path "$OUT" r all_lite reset
