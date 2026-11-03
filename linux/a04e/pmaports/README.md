# A04e postmarketOS port overlay

This directory is the MT-OS working overlay for a future contribution to
postmarketOS `pmaports`. It follows the upstream split between:

- `device-samsung-a04e`: device package, `APKBUILD`, and `deviceinfo`
- `linux-samsung-a04e`: kernel package, config fragments, and patches

## Build target

- Architecture: `aarch64`
- Distribution: postmarketOS edge (Alpine)
- UI: Phosh
- Build engine: `pmbootstrap`
- Package recipes: Alpine `APKBUILD` recipes, using the pmaports conventions

## Kernel tracks

The downstream candidate is pinned in `../kernel-sources.json` to the
archived A042F Samsung kernel repository and its `a04e` branch commit.
Its reported kernel base is 4.19.191. The source tree contains both
`a04e_defconfig` and `a04e_00_defconfig`; the larger `a04e_defconfig` is the
initial candidate. The uploaded live-device report confirms the kernel release
but does not include `/proc/config.gz`, so the source defconfig has not yet
been compared with the running configuration. This remains a research input,
not a verified postmarketOS kernel package.

The mainline track is kept separate. It must not inherit vendor-kernel
boot assumptions, patches, or configuration. A mainline port needs a
working MT6765 device tree, clocks, regulators, pinctrl, storage, display,
touch and bootloader hand-off support.

## Why the APKBUILD/deviceinfo are not fabricated yet

The uploaded handset report now establishes by-name mappings for boot
(`mmcblk0p37`), recovery (`mmcblk0p38`), DTBO (`mmcblk0p12`), vbmeta
(`mmcblk0p13`), super (`mmcblk0p44`) and userdata (`mmcblk0p50`). It does not
provide partition sizes, boot-image headers, DTB/DTBO contents, panel/touch
bindings, or a verified safe recovery procedure. Those details control the
device package and boot-deploy behavior.
Inventing them could create an image that looks complete but cannot boot, or
could direct a future flashing step at the wrong partition.

The diagnostic findings are recorded in `../DIAGNOSTIC-FINDINGS.md`. The next
valid step is to compare the running `/proc/config.gz` with the source defconfig
and inspect boot/recovery image metadata read-only. Then add the device package
and downstream kernel package with verified values.
Only after that should CI run `pmbootstrap build`, `pmbootstrap install`,
and `pmbootstrap export`.

## Current status

No device package, bootable kernel, generated postmarketOS image, or verified
flash procedure exists yet. The branch is not flashable.
