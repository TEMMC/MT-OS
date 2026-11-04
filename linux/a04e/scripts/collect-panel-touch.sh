#!/system/bin/sh
# Read-only A04e panel/touch identification report.
# Run: su -c sh ./collect-panel-touch.sh
set -u
OUT_BASE="/sdcard/Download"
STAMP="$(date +%Y%m%d-%H%M%S 2>/dev/null || echo unknown)"
OUT="$OUT_BASE/MT-A04e-PanelTouch-$STAMP"
mkdir -p "$OUT" || exit 1
REPORT="$OUT/panel-touch-report.txt"

{
  echo "Samsung A04e panel/touch read-only report"
  echo "Generated: $STAMP"
  echo
  echo "== Kernel and board =="
  uname -a
  for p in ro.product.model ro.product.device ro.hardware ro.boot.hardware ro.soc.model; do
    printf '%s=' "$p"; getprop "$p" 2>/dev/null
  done
  echo
  echo "== Runtime panel identifiers =="
  for f in /proc/lcm /proc/devinfo/lcm /proc/devinfo/lcd /sys/class/graphics/fb0/name \
           /sys/class/graphics/fb0/modes /sys/class/graphics/fb0/virtual_size; do
    if [ -r "$f" ]; then echo "--- $f"; cat "$f" 2>/dev/null; fi
  done
  echo
  echo "== Panel/touch-related device tree strings =="
  for root in /proc/device-tree /sys/firmware/devicetree/base; do
    [ -d "$root" ] || continue
    find "$root" -type f \( -name compatible -o -name name -o -name status -o -name label \) 2>/dev/null |
    while IFS= read -r f; do
      v="$(tr '\000' ' ' < "$f" 2>/dev/null)"
      case "$v $f" in
        *lcm*|*lcd*|*panel*|*display*|*touch*|*jadard*|*chipone*|*gcore*|*jd9365*|*gc7202*|*nl9911*)
          echo "--- $f"; echo "$v";;
      esac
    done
  done
  echo
  echo "== Input device details =="
  cat /proc/bus/input/devices 2>/dev/null
  for f in /sys/class/input/input*/name /sys/class/input/input*/device/modalias \
           /sys/class/input/input*/device/uevent; do
    [ -r "$f" ] && { echo "--- $f"; cat "$f" 2>/dev/null; }
  done
  echo
  echo "== Relevant kernel log lines =="
  dmesg 2>/dev/null | grep -iE 'lcm|lcd|panel|dsi|backlight|jadard|jd9365|chipone|tddi|gcore|touchscreen|touch panel' | tail -n 400
} > "$REPORT" 2>&1

echo "Report created: $REPORT"
echo "Review it for serial numbers, addresses or other private values before sharing."
echo "No partitions, settings or device-tree data were modified."
