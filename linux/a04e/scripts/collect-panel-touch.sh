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
  for f in /proc/lcm /proc/devinfo/lcm /proc/devinfo/lcd \
           /sys/firmware/devicetree/base/atag,videolfb-lcmname \
           /proc/device-tree/atag,videolfb-lcmname \
           /sys/class/graphics/fb0/name /sys/class/graphics/fb0/modes \
           /sys/class/graphics/fb0/virtual_size /sys/class/graphics/fb0/device/uevent; do
    if [ -r "$f" ]; then echo "--- $f"; tr '\\000' ' ' < "$f" 2>/dev/null; echo; fi
  done
  echo
  echo "== SPI touchscreen binding =="
  for d in /sys/bus/spi/devices/*; do
    [ -e "$d" ] || continue
    case "$d" in *spi1.1*|*spi1.0*|*spi1.2*) ;;
      *) continue ;;
    esac
    echo "--- $d"
    for f in "$d/modalias" "$d/uevent" "$d/of_node/compatible" "$d/of_node/status"; do
      [ -r "$f" ] && { echo "[$f]"; tr '\\000' ' ' < "$f" 2>/dev/null; echo; }
    done
    [ -L "$d/driver" ] && echo "driver=$(readlink "$d/driver")"
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
  for f in /sys/class/input/input*/name /sys/class/input/input*/phys \
           /sys/class/input/input*/device/modalias /sys/class/input/input*/device/uevent \
           /sys/class/input/input*/device/of_node/compatible; do
    [ -r "$f" ] && { echo "--- $f"; tr '\\000' ' ' < "$f" 2>/dev/null; echo; }
  done
  for d in /sys/class/input/input*; do
    [ -e "$d" ] || continue
    [ -L "$d/device/driver" ] && echo "$d driver=$(readlink "$d/device/driver")"
  done
  echo
  echo "== Relevant kernel log lines =="
  dmesg 2>/dev/null | grep -iE 'lcm|lcd|panel|dsi|ddp|mtkfb|framebuffer|backlight|jadard|jd9365|chipone|tddi|gcore|touchscreen|touch panel|spi1' | tail -n 800
} > "$REPORT" 2>&1

echo "Report created: $REPORT"
echo "Review it for serial numbers, addresses or other private values before sharing."
echo "No partitions, settings or device-tree data were modified."
