#!/system/bin/sh
# Read-only hardware inventory for the MT Linux A04e port.
# Run from Termux: su -c sh ./collect-a04e.sh [--include-dtb]
set -u

OUT_BASE="/sdcard/Download"
STAMP="$(date +%Y%m%d-%H%M%S 2>/dev/null || echo unknown)"
OUT="$OUT_BASE/MT-Linux-A04e-$STAMP"
INCLUDE_DTB=0
[ "${1:-}" = "--include-dtb" ] && INCLUDE_DTB=1

mkdir -p "$OUT" || { echo "Cannot create $OUT"; exit 1; }
report="$OUT/device-report.txt"

{
  echo "MT Linux A04e read-only diagnostic report"
  echo "Generated: $STAMP"
  echo
  echo "== Model and platform =="
  for p in ro.product.manufacturer ro.product.model ro.product.device ro.product.board \
           ro.hardware ro.boot.hardware ro.soc.manufacturer ro.soc.model \
           ro.build.version.release ro.build.version.sdk ro.vendor.build.version.sdk \
           ro.treble.enabled ro.product.cpu.abi ro.vndk.version ro.vndk.lite; do
    printf '%s=' "$p"; getprop "$p" 2>/dev/null
  done
  echo
  echo "== Kernel =="
  uname -a
  cat /proc/version 2>/dev/null
  echo
  echo "== Device tree compatible strings =="
  if [ -r /proc/device-tree/compatible ]; then
    tr '\000' '\n' < /proc/device-tree/compatible
  elif [ -r /sys/firmware/devicetree/base/compatible ]; then
    tr '\000' '\n' < /sys/firmware/devicetree/base/compatible
  else
    echo "Device-tree compatible property unavailable"
  fi
  echo
  echo "== Memory =="
  grep -E 'MemTotal|MemAvailable|MemFree|SwapTotal|SwapFree' /proc/meminfo 2>/dev/null
  echo
  echo "== Input devices =="
  for f in /sys/class/input/input*/name; do
    [ -r "$f" ] && printf '%s: ' "$f" && cat "$f"
  done
  echo
  echo "== DRM devices =="
  ls -l /dev/dri 2>/dev/null || true
  echo
  echo "== Display and graphics modules =="
  for f in /sys/class/drm/card*/device/uevent /sys/class/graphics/fb*/name; do
    [ -r "$f" ] && { echo "--- $f"; cat "$f"; }
  done
  echo
  echo "== Partition names and sizes (no partition contents) =="
  for f in /dev/block/by-name/* /dev/block/bootdevice/by-name/*; do
    [ -e "$f" ] && ls -l "$f"
  done
  echo
  echo "== Mounted filesystems =="
  cat /proc/mounts 2>/dev/null
  echo
  echo "== Kernel configuration availability =="
  if [ -r /proc/config.gz ]; then
    echo "/proc/config.gz available (not expanded in this report)"
  elif [ -r /sys/kernel/kconfig.gz ]; then
    echo "/sys/kernel/kconfig.gz available (not expanded in this report)"
  else
    echo "No readable kernel config export found"
  fi
} > "$report" 2>&1

if [ "$INCLUDE_DTB" -eq 1 ]; then
  if [ -r /sys/firmware/fdt ]; then
    cat /sys/firmware/fdt > "$OUT/booted-device-tree.dtb"
    echo "Included booted-device-tree.dtb. Review it before sharing." >> "$report"
  else
    echo "Requested DTB export, but /sys/firmware/fdt is unavailable." >> "$report"
  fi
fi

echo "Report created: $OUT"
echo "Review device-report.txt before sharing it."
echo "No partitions or system settings were modified."
