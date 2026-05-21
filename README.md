# ZTE F50 - Downgrade, Root, Unlock BL and Patch Modem Toolkit

A small Windows toolkit of `.bat` scripts wrapping `spd_dump.exe` for the
ZTE F50 (Unisoc / Spreadtrum platform, firmware **B09**). Lets you:

- **Back up** every partition before touching anything.
- **Downgrade / flash** the B09 ROM.
- **Root** the device (Magisk-patched boot image).
- **Unlock the bootloader** (patched trustos).
- **Patch the modem** to allow modem modification writing via engineer mode AT commands -
  and **restore** the original modem if you change your mind.

> **READ THIS FIRST.**
> Flashing is destructive. The first thing you should ever do with this toolkit
> is run a **full backup**. If anything goes wrong later, the backup is the
> only way to get your device back.

---

## Contents

```
.
├── backup_direct.bat              # Full backup, direct USB (kickto 2)
├── backup_shortcircuit.bat        # Full backup, test-point/short mode
├── flash-rom_direct.bat           # Flash ROM in zte-f50-b09\, direct USB (wipes userdata)
├── flash-rom_shortcircuit.bat     # Flash ROM in zte-f50-b09\, test-point mode (wipes userdata)
├── flash-root_direct.bat          # Post-flash root via direct USB (B09 only)
├── unlock-bl.bat                  # Flash patched trustos to unlock bootloader
├── patch-modem.bat                # Pull current modem, save original, patch, flash
├── restore-modem.bat              # Re-flash the saved original modem
├── patch_modem.py                 # Hex patcher used by patch-modem.bat
├── bin\                           # spd_dump + FDLs + patched trustos + Magisk boot
├── zte-f50-b09\                   # B09 ROM partition .bin files (pre-populated)
├── drivers\                       # SPD/Unisoc USB drivers for Win7/8/10
├── temp\                          # Scratch directory used during flashing
├── backups\
│   └── backup_YYYY-MM-DD_HH-MM-SS\  # Full-device backups (auto-created)
└── bootloader-unlocked-and-patched\ # patch-modem.bat output (auto-created)
    ├── modem_original_*.bin         #   untouched, used for restore
    └── modem_patched_*.bin          #   what got flashed
```

---

## Two connection modes

The scripts come in two flavours. Pick the one your device needs.

### Direct USB mode (`*_direct.bat`)

1. Power the device fully **off**.
2. Start the script.
3. When it prints `Waiting for device...`, plug the USB cable in.
4. `spd_dump` uses `--kickto 2` to kick the device into download mode.

> Direct mode on F50 is **flaky** — the bootrom doesn't always accept the
> kick on a cold boot, and you can see "Error writing to serial port". The
> built-in retry loop will let you unplug, press a key, and try again as
> many times as you need. Be patient: it often takes several attempts.

### Short-circuit / test-point mode (`*_shortcircuit.bat`)

Use this when direct mode keeps failing, or the device is bricked / in a
bootloop.

1. Power the device fully **off**.
2. Start the script.
3. When it prints `Waiting for device...`:
   - Short the debug/test points on the board.
   - Plug the USB cable in **while still shorting**.
   - Release the test points once the progress bar appears.

> Never start these scripts with the phone already powered on. Download-mode
> flashing always begins from a powered-off device.

---

## Enable USB debugging on the F50 (one-time setup)

The F50's USB port has to be switched into debug mode via the device's
web admin panel before any of the flashing tools can talk to it.

1. Log in to the F50 management backend in your browser (usually
   `http://192.168.0.1/`).
2. In the same browser, open this URL in a **new tab**:
   ```
   http://192.168.0.1/index.html#usb_port
   ```
3. Enable USB debugging from that page.

You only need to do this once per device. After it's enabled, proceed
to the prerequisites below.

---

## Prerequisites

1. **Install the SPD/Unisoc USB drivers** from `drivers\` (pick `Win10`,
   `Win8`, or `Win7` to match your machine). Do this **before** plugging
   the device in for the first time.
2. **The B09 ROM partition files live in `zte-f50-b09\`** (pre-populated in
   this toolkit). The flash scripts read every `*.bin` from that folder and
   write them to the matching partitions.
3. Run the scripts from the toolkit folder (double-click is fine). They use
   relative paths anchored to the script location, so don't move individual
   `.bat` files out of this folder.
4. **For `patch-modem.bat` only:** Python 3 must be installed and on
   `PATH`. The `colorama` package is installed automatically the first
   time `patch_modem.py` runs (no manual `pip install` step needed).

---

## Typical workflow

```
1. Install drivers from drivers\
2. backup_direct.bat   (or backup_shortcircuit.bat if direct doesn't work)
   -> Verify backups\backup_<timestamp>\ contains the dumped .bin files
3. flash-rom_direct.bat   (or flash-rom_shortcircuit.bat)
   -> Device reboots into the B09 ROM
4. flash-root_direct.bat  (optional - only if you want Magisk root)
5. unlock-bl.bat          (REQUIRED before patch-modem.bat - see below)
6. patch-modem.bat        (optional - enable modem modification writing via AT commands)
```

You can stop at any step. Everything past step 3 is optional **except**:
step 5 MUST come before step 6. Flashing a patched modem onto a locked
bootloader bricks the device. `patch-modem.bat` will refuse to write
unless you confirm the BL is unlocked, but the dependency is real - don't
skip step 5 if you plan to run step 6.

---

## Script reference

| Script                          | Connection mode | What it does                                                                           |
|---------------------------------|-----------------|----------------------------------------------------------------------------------------|
| `backup_direct.bat`             | Direct USB      | Reads ALL partitions into `backups\backup_<timestamp>\`                                |
| `backup_shortcircuit.bat`       | Short-circuit   | Same as above, but boots `fdl1-dl.bin` + `fdl2-dl.bin` first                           |
| `flash-rom_direct.bat`          | Direct USB      | Writes every `.bin` in `zte-f50-b09\` to its partition, erases `userdata`, resets      |
| `flash-rom_shortcircuit.bat`    | Short-circuit   | Same as above, but boots `fdl1-dl.bin` + `fdl2-dl.bin` first                           |
| `flash-root_direct.bat`         | Direct USB      | Writes patched `trustos` + Magisk-patched boot image, resets. **System must be B09.**  |
| `unlock-bl.bat`                 | Direct USB      | Writes `bin\out_tos.bin` to `trustos` to unlock the bootloader, resets                 |
| `patch-modem.bat`               | Direct USB      | Source = device pull / drag-drop file / B09 ROM modem; archives source, patches, flashes |
| `restore-modem.bat`             | Direct USB      | Re-flashes the most recent `modem_original_*.bin` to `nr_modem_a`                      |

### Backups are timestamped

Each full backup goes into its own folder named:

```
backups\backup_YYYY-MM-DD_HH-MM-SS\
```

Modem patches save their own timestamped pair to
`bootloader-unlocked-and-patched\`:

```
bootloader-unlocked-and-patched\modem_original_<timestamp>.bin   # untouched, used for restore
bootloader-unlocked-and-patched\modem_patched_<timestamp>.bin    # what got flashed
```

### Flash scripts ask before wiping

`flash-rom_*` scripts erase `userdata`. They prompt with a Y/N confirmation
before doing anything, so you can bail out if you launched the wrong one.

### Automatic retry on failure

All scripts run in a retry loop. If a connection fails — wrong port,
"Error writing to serial port", timeout, etc. — you'll see:

```
[FAILED] ... attempt #N did NOT succeed.

To try again:
  1) UNPLUG the USB cable from the device.
  2) Make sure the device is fully powered OFF.
  3) Press any key when ready - the script will wait for the device
     again, then plug the USB cable back in.

Press Ctrl+C to give up, or any other key to retry...
```

The next attempt gets a fresh `=== Attempt #N+1 ===` header (and, for
backups, a brand new timestamped folder — empty failed folders are deleted
automatically so the `backups\` directory stays clean).

---

## Rooting notes

`flash-root_direct.bat` writes:

- `bin\f50b09_t.bin`        → `trustos` partition (patched for unlock)
- `bin\magiskf50b09.img`    → `boot` partition (pre-patched with Magisk)

It only makes sense **after** the device is already running stock **B09**.
After the reboot the Magisk daemon will be active but you still need to
install the Magisk Manager APK on the device to use it.

---

## Bootloader unlock

`unlock-bl.bat` flashes a patched `trustos` image (`bin\out_tos.bin`) that
disables the verified-boot check used by the bootloader. After it finishes
and the device reboots, the bootloader is unlocked.

This is independent of root: you can unlock without rooting, or root
without unlocking. They just both happen to touch the `trustos` partition,
which is why `unlock-bl.bat` writes a different `trustos` image than
`flash-root_direct.bat`. Pick one or the other - don't run both back-to-back
without thinking, since each overwrites the previous one's `trustos`.

### Don't try to re-lock the bootloader

This toolkit deliberately does **not** ship a re-lock script. Once you've
unlocked, the recommended state is "stay unlocked".

If you put the original `trustos` back while the modem (or any other
vbmeta-covered partition) is still patched, the verified-boot chain will
reject the running image and the device will either hard-brick or land in
a bootloop. You'd need short-circuit mode + a full re-flash to recover.

So in practice:

- **Unlocked + patched modem** → modem modification writing works. ✅
- **Locked + stock everything** → factory state. ✅
- **Locked + patched modem** → 🧱 brick.

If you genuinely need to go back to stock, do a full flash from
`zte-f50-b09\` (which restores the stock `trustos` and modem together) -
don't cherry-pick `trustos` on its own.

---

## Modem patch (modem modification writing) and restore

> **⚠️ Unlock the bootloader BEFORE running this.** A locked bootloader
> runs verified-boot on `nr_modem_a` / `nr_modem_b`; a patched modem will
> fail that check and the device will brick or bootloop on the next boot.
> Run `unlock-bl.bat` first. `patch-modem.bat` will pause and ask you to
> confirm the BL is unlocked before it actually writes anything to the
> device, so you have a final safety stop - but knowing this up front
> saves you a wasted patch run.

`patch-modem.bat` enables modem modification writing through the engineer-mode AT command
interface. It does **not** ship a pre-built patched modem; instead, at
startup it asks you where the source modem should come from:

- **[D] Pull from device** (recommended) - reads `nr_modem_a` from the
  attached F50.
- **[F] Use an existing file** - type/paste a path, or **drag-and-drop**
  a `.bin` onto the cmd window. Useful when you already extracted the
  modem (e.g. from a full backup in `backups\backup_*\nr_modem_a.bin`)
  or got one from somewhere else.
- **[B] Use the B09 ROM modem** - takes `zte-f50-b09\nr_modem_a.bin`
  straight out of the ROM folder, no device read needed. Only valid
  **right after** you flashed the B09 ROM with `flash-rom_*.bat`; the
  script asks you to confirm "yes, I just flashed B09" first. Skips the
  pull step entirely, so the device only needs to be connected once (for
  the final flash).

The rest of the flow is the same either way:

1. The source modem is saved untouched as
   `bootloader-unlocked-and-patched\modem_original_<timestamp>.bin` —
   this is your restore point.
2. `patch_modem.py` runs on it. The patcher looks for the byte sequence
   `05 24 0B E0 30 68 03`, shows a colourful hex view, asks you to
   confirm, and changes the first byte from `0x05` to `0x01`. The result
   is saved as `modem_patched_<timestamp>.bin`.
3. The script asks you to connect the device, then flashes the patched
   copy back to `nr_modem_a`.

Each spd_dump step has its own retry loop. Step 2 (the patch) is purely
local and can be re-run by hand if needed:

```
python patch_modem.py <input.bin> <output.bin>
```

> **If you supply your own file**, make sure it actually belongs to this
> device. `restore-modem.bat` later picks the newest
> `modem_original_*.bin` to re-flash, so a foreign modem in that folder
> would be a brick waiting to happen on a future restore.

### After flashing

Open the dialer and enter:

```
*#*#83781#*#*
```

Go to "AT Command" and use:

```
AT+SPIMEI=0,"NEW_modem modification"
```

Replace `NEW_modem modification` with your desired 15-digit modem modification code 😁.

### Restoring the original modem

If anything looks off after patching (no signal, weird baseband behaviour,
etc.), run `restore-modem.bat`. It picks the **newest**
`bootloader-unlocked-and-patched\modem_original_*.bin` and flashes it
back to `nr_modem_a`.

If you have multiple originals and want to restore an older one, rename it
to have a newer timestamp before running the script, or edit the script
to point at a specific file.

### Legal warning

modem modification changing without explicit manufacturer authorisation is a criminal
offence in most jurisdictions (including the EU, UK, US, and Turkey).
The legitimate use of `patch-modem.bat` is **restoring your own original
modem modification after a wipe** - that's also exactly what `restore-modem.bat` exists
for. Anything else is on you.

---

## Troubleshooting

- **Progress bar never starts.**
  Driver isn't installed correctly, or the device isn't actually in download
  mode. Re-check `drivers\`, make sure the device is powered off before
  plugging in, and try short-circuit mode if direct mode doesn't react.

- **`spd_dump.exe` exits with "Error writing to serial port".**
  Classic direct-mode kickto failure on F50. Just let the retry loop keep
  going; eventually it tends to land. If it never works, switch to a
  `*_shortcircuit.bat` script.

- **`spd_dump.exe` exits immediately with "unknown option".**
  Someone replaced `bin\spd_dump.exe` with the upstream build from
  [github.com/ilyakurdyukov/spreadtrum_flash](https://github.com/ilyakurdyukov/spreadtrum_flash).
  That build is **not** command-compatible with these scripts - this toolkit
  ships a custom fork that adds `--kickto`, `exec`, `path`, `r all`,
  `write_parts`, `w <part>`, etc. Restore the bundled binary
  (a `.upstream-*` backup may exist next to it).

- **You see Chinese text from `spd_dump`.**
  That's `spd_dump`'s own output; it's not from these scripts.

- **`patch-modem.bat` says "Python is not installed or not on PATH".**
  Install Python 3 from python.org (tick "Add to PATH" during install)
  and re-run. The `colorama` package is installed automatically by
  `patch_modem.py` on first run if it's missing.

- **You ran the wrong flash script and the device is bricked.**
  Use `flash-rom_shortcircuit.bat` to re-flash from `zte-f50-b09\`. This is
  exactly why step 1 of the workflow is "make a backup".

---

## Final warning

**BACK UP FIRST. BACK UP FIRST. BACK UP FIRST.**

No backup = no recovery if the flash goes wrong.
