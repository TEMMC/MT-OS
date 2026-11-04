# A04e postmarketOS port overlay

This directory is the MT-OS working overlay for a future contribution to
postmarketOS `pmaports`. It follows the upstream split between:

- `device-samsung-a04e`: device package, `APKBUILD`, and `deviceinfo`
- `linux-samsung-a04e`: kernel package, config fragment, and patches

## Build target

- Architecture: `aarch64`
- Distribution: postmarketOS edge (Alpine)
- Intended UI: Phosh (not yet usable; no verified DRM/KMS display path)
- Build engine: `pmbootstrap`
- Package recipes: Alpine `APKBUILD` recipes, using pmaports conventions

## Kernel tracks

The downstream candidate is pinned in `../kernel-sources.json` to the
archived Samsung A04e kernel repository and commit
`7c1b304f2df8df4c85abe6fe84b8238d7521bd58`. Its reported kernel base is
4.19.191. The running `/proc/config.gz` was verified byte-for-byte against
`arch/arm64/configs/a04e_defconfig`.

The mainline track remains separate. It must not inherit vendor-kernel boot
assumptions, patches or configuration. The inspected current upstream
MediaTek DRM match table does not include MT6765 MMSYS support, so a usable
mainline display path cannot be assumed. Mainline work needs explicit
validation of the MT6765 display controller, clocks, DSI host, panel, pinctrl,
regulators, storage and bootloader hand-off.

## Hardware findings

The actual boot image and DTBO were parsed read-only. The boot image uses
Android boot header v2. The DTBO contains one valid FDT overlay whose
compatible strings identify Samsung A04e / MT6765.

The device-specific DTS includes the Samsung HS04 board DTS. The downstream
defconfig enables the MediaTek vendor framebuffer and LCM stack, and lists
seven candidate 720x1600 panel drivers. The actual physical panel variant is
not yet known. The HS04 touchscreen DTSI describes Chipone, Jadard and
GalaxyCore SPI candidates; runtime diagnostics previously showed
`jadard-touchscreen`, but the exact physical controller still needs
confirmation.

## Package and build status

Initial pmaports package recipes now exist under
`device/testing/linux-samsung-a04e` and
`device/testing/device-samsung-a04e`. They are bring-up scaffolding, not
validated packages. The kernel recipe pins the downstream source and its
documented Clang r383902 / ARM GNU 14.2 toolchains. A dedicated GitHub Actions
workflow attempts a real kernel compile and records toolchain hashes. Review
those hashes before treating the toolchains as trusted/release inputs.

The deviceinfo deliberately sets `deviceinfo_flash_method="none"` and
`deviceinfo_drm="false"`. No boot image generation, partition flashing,
panel choice, or touchscreen choice is guessed.

See `../DISPLAY-TOUCH-PORTING-ANALYSIS.md` and
`../DIAGNOSTIC-FINDINGS.md` for detailed findings.

## Current status

The kernel and device package recipes have not yet passed a pmbootstrap build.
The downstream kernel has not yet passed the new GitHub Actions compile.
No diagnostic initramfs, native Linux boot, working DRM/KMS display,
touchscreen bring-up, Phosh session, generated postmarketOS image, or verified
flash procedure exists yet. The branch is not flashable.
