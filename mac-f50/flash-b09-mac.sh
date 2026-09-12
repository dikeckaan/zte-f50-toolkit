#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SPD="$ROOT/bin/spd_dump"
ROM="${1:-$ROOT/../zte-f50-b09}"
[[ -x "$SPD" ]] || { echo "Önce ./install-mac.sh çalıştır" >&2; exit 1; }
[[ -d "$ROM" ]] || { echo "ROM klasörü bulunamadı: $ROM" >&2; exit 1; }
files=("$ROM"/*.bin)
(( ${#files} > 0 )) || { echo "ROM klasöründe .bin yok" >&2; exit 1; }
echo "UYARI: B09 ROM flash userdata dahil bölümleri değiştirebilir."
read -r "reply?Devam etmek için FLASH yaz: "
[[ "$reply" == FLASH ]] || { echo "İptal edildi."; exit 1; }
args=(--wait 300 --verbose 1 --kickto 2 path "$ROOT")
for f in "${files[@]}"; do
  name="${f:t:r}"
  [[ "$name" == userdata || "$name" == cache || "$name" == blackbox ]] && continue
  args+=(w "$name" "$f")
done
args+=(reset)
exec "$SPD" "${args[@]}"
