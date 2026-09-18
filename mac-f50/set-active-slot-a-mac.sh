#!/bin/zsh
# Select Android boot slot A on the ZTE F50 using spd_dump's built-in,
# CRC-checked A/B boot-control writer. This writes only misc+0x800 (32 bytes).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DUMP="$ROOT/bin/spd_dump"
STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
EVIDENCE="$ROOT/../evidence-slot-a-selected-$STAMP"

if [[ ! -x "$DUMP" ]]; then
  print -u2 "spd_dump was not found at: $DUMP"
  exit 1
fi

print "This selects slot A by writing only the 32-byte Android boot-control record"
print "at misc+0x800. It does not write firmware, modem/NV data, GPT, or userdata."
print "Evidence will be saved to: $EVIDENCE"
print -n "Type SWITCH_TO_SLOT_A to continue: "
read -r CONFIRM

if [[ "$CONFIRM" != "SWITCH_TO_SLOT_A" ]]; then
  print "Cancelled; no device writes were made."
  exit 0
fi

mkdir -p "$EVIDENCE"

"$DUMP" --wait 300 --verbose 1 --kickto 2 \
  set_active a \
  path "$EVIDENCE" \
  r misc

print "Slot-A selection and misc readback were requested."
print "At FDL2 >, press Ctrl+C. Do not type reset; unplug USB and boot normally."
