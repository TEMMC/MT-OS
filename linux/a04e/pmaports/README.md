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
archived Samsung A04e kernel repository and commit
`7c1b304f2df8df4c85abe6fe84b8238d7521bd58`. Its reported kernel base is
4.19.191. The running `/proc/config.gz` has been compared byte-for-byte with
`arch/arm64/configs/a04e_defconfig`; the source defconfig is verified.

The mainline track remains separate. It must not inherit vendor-kernel boot
assumptions, patches or configuration. The inspected current upstream
MediaTek DRM match table does not include MT6765 MMSYS support, so a usable
mainline display path cannot be assumed. Mainline work needs explicit
validation of the MT6765 display controller, clocks, DSI host, panel, pinctrl,
regulators, storage and bootloader hand-off.

## Hardware findings

The actual boot image and DTBO have now been parsed read-only. The boot image
uses Android boot header v2. The DTBO contains one valid FDT overlay whose
compatible strings identify Samsung A04e / MT6765.

The device-specific DTS includes the Samsung HS04 board DTS. The downstream
defconfig enables the MediaTek vendor framebuffer and LCM stack, and lists
seven candidate 720x1600 panel drivers. The actual physical panel variant is
not yet known. The HS04 touchscreen DTSI describes Chipone, Jadard and
GalaxyCore SPI candidates; the exact populated controller still needs
confirmation.

See `../DISPLAY-TOUCH-PORTING-ANALYSIS.md` and
`../DIAGNOSTIC-FINDINGS.md` for the detailed source and device findings.

## Why the package recipes are not fabricated yet

The device and kernel packages must use the verified board identity, correct
kernel build process, actual display/touch variants, and a tested boot
strategy. The downstream kernel is archived and uses a vendor-specific
MediaTek display stack; it cannot be treated as a ready-made upstream DRM
kernel. A kernel package may be drafted, but a successful build and diagnostic
boot must be verified separately.

The next engineering gate is to establish the legacy kernel's reproducible
build toolchain and compile it in CI, while continuing the panel and touch
variant investigation. Do not invent a flash deployment recipe.

## Current status

No device package, bootable kernel, generated postmarketOS image, or verified
flash procedure exists yet. The branch is not flashable.
