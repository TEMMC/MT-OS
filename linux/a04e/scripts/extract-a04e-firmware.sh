#!/system/bin/sh
# Read-only extraction of A04e firmware/configuration needed for native Linux bring-up.
# Run in Termux:
#   su -c sh ./extract-a04e-firmware.sh
# Optional (large; reads modem firmware partitions too):
#   su -c sh ./extract-a04e-firmware.sh --include-modem-partitions
set -u

OUT_BASE="/sdcard/Download"
STAMP="$(date +%Y%m%d-%H%M%S 2>/dev/null || echo unknown)"
WORK="$OUT_BASE/MT-A04e-Firmware-$STAMP"
STAGE="$WORK/root"
REPORT="$WORK/extraction-report.txt"
INCLUDE_MODEM=0
[ "${1:-}" = "--include-modem-partitions" ] && INCLUDE_MODEM=1

if [ "$(id -u 2>/dev/null)" != "0" ]; then
  echo "ERROR: root is required. Run: su -c sh ./extract-a04e-firmware.sh"
  exit 1
fi

mkdir -p "$STAGE" || exit 1
: > "$REPORT"
log() { echo "$*" | tee -a "$REPORT"; }

log "MT Linux A04e stock firmware extraction"
log "Timestamp: $STAMP"
log "Model: $(getprop ro.product.model 2>/dev/null)"
log "Device: $(getprop ro.product.device 2>/dev/null)"
log "SoC: $(getprop ro.soc.model 2>/dev/null)"
log "This script reads firmware/config files only; it does not write partitions."

copy_tree() {
  src="$1"
  dest="$2"
  if [ -d "$src" ]; then
    mkdir -p "$dest"
    # Dereference firmware symlinks so the archive remains usable off-device.
    cp -rL "$src"/. "$dest"/ 2>>"$REPORT"
    log "COPIED directory: $src"
  elif [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    cp -L "$src" "$dest" 2>>"$REPORT"
    log "COPIED file: $src"
  else
    log "NOT PRESENT: $src"
  fi
}

# Firmware/config directories most relevant to MTK combo, WLAN, BT, GNSS,
# audio, camera, sensors and platform co-processors.
copy_tree /vendor/firmware "$STAGE/vendor/firmware"
copy_tree /vendor/etc/firmware "$STAGE/vendor/etc/firmware"
copy_tree /odm/firmware "$STAGE/odm/firmware"
copy_tree /odm/etc/firmware "$STAGE/odm/etc/firmware"
copy_tree /system/vendor/firmware "$STAGE/system/vendor/firmware"
copy_tree /vendor/etc/wifi "$STAGE/vendor/etc/wifi"
copy_tree /vendor/etc/bluetooth "$STAGE/vendor/etc/bluetooth"
copy_tree /vendor/etc/gps "$STAGE/vendor/etc/gps"
copy_tree /vendor/etc/sensors "$STAGE/vendor/etc/sensors"
copy_tree /vendor/etc/audio "$STAGE/vendor/etc/audio"
copy_tree /vendor/etc/camera "$STAGE/vendor/etc/camera"
copy_tree /vendor/etc/vintf "$STAGE/vendor/etc/vintf"

# Capture module names and loaded-driver inventory, not the whole vendor
# partition or unrelated user data.
{
  echo "== Kernel and properties =="
  uname -a
  for p in ro.product.model ro.product.device ro.hardware ro.soc.model \
           ro.build.version.release ro.vendor.build.version.sdk \
           ro.boot.hardware; do
    printf '%s=' "$p"; getprop "$p" 2>/dev/null
  done
  echo
  echo "== Loaded kernel modules =="
  cat /proc/modules 2>/dev/null
  echo
  echo "== Module locations =="
  for d in /vendor/lib/modules /vendor_dlkm/lib/modules /odm/lib/modules \
           /system/lib/modules /lib/modules; do
    [ -d "$d" ] && find "$d" -type f 2>/dev/null
  done
  echo
  echo "== Firmware search roots =="
  for d in /vendor/firmware /vendor/etc/firmware /odm/firmware \
           /odm/etc/firmware /system/vendor/firmware; do
    [ -d "$d" ] && find "$d" -type f 2>/dev/null
  done
  echo
  echo "== Modem/MTK device nodes =="
  ls -l /dev/ccci* /dev/eccci* /dev/ttyC* /dev/stp* /dev/wmt* 2>/dev/null
  echo
  echo "== Modem/firmware partition names =="
  for f in /dev/block/by-name/* /dev/block/bootdevice/by-name/*; do
    [ -e "$f" ] || continue
    n="${f##*/}"
    case "$n" in *md1*|*modem*|*scp*|*sspm*|*conn*|*wifi*|*bt*|*gps*)
      ls -l "$f";;
    esac
  done
  echo
  echo "== Relevant kernel log =="
  dmesg 2>/dev/null | grep -iE 'wlan|wifi|conninfra|consys|mtk_wcn|btif|bluetooth|wmt|gps|gnss|md1|ccci|eccci|modem|firmware|mt6357|charger|battery|audio|codec|sensor|camera' | tail -n 1200
} > "$STAGE/device-inventory.txt" 2>&1
log "Captured device inventory and module list."

if [ "$INCLUDE_MODEM" -eq 1 ]; then
  mkdir -p "$STAGE/modem-partitions"
  for f in /dev/block/by-name/* /dev/block/bootdevice/by-name/*; do
    [ -e "$f" ] || continue
    n="${f##*/}"
    case "$n" in
      md1img|md1dsp|md1arm7|md1rom|md1mcu|modem|modem_a|modem_b)
        # These are read-only source copies. Skip aliases already copied.
        out="$STAGE/modem-partitions/$n.img"
        if [ ! -e "$out" ]; then
          if dd if="$f" of="$out" bs=4M 2>>"$REPORT"; then
            log "COPIED modem partition: $n"
          else
            rm -f "$out"
            log "FAILED modem partition read: $n"
          fi
        fi
        ;;
    esac
  done
else
  log "Modem partition images skipped. Re-run with --include-modem-partitions if requested."
fi

# Produce file inventory and hashes for integrity checking.
(
  cd "$STAGE" || exit 1
  find . -type f 2>/dev/null | sort > "$WORK/file-list.txt"
  if command -v sha256sum >/dev/null 2>&1; then
    find . -type f -exec sha256sum {} \; > "$WORK/SHA256SUMS.txt"
  fi
)

ARCHIVE="$OUT_BASE/MT-A04e-Firmware-$STAMP.tar.gz"
tar -czf "$ARCHIVE" -C "$WORK" root extraction-report.txt file-list.txt SHA256SUMS.txt 2>>"$REPORT"
if [ -s "$ARCHIVE" ]; then
  log "ARCHIVE: $ARCHIVE"
  ls -lh "$ARCHIVE" | tee -a "$REPORT"
else
  log "ERROR: archive creation failed"
  exit 1
fi

log "Extraction finished. Review the archive contents before sharing."
log "No partition was written, erased, formatted or flashed."
