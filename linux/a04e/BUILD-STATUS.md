# A04e native postmarketOS build status

## Selected build profile

| Setting | Selection |
|---|---|
| Build environment | GitHub Actions |
| Build system | pmbootstrap / Alpine APKBUILD |
| Package repository format | pmaports overlay |
| Distribution target | postmarketOS edge |
| Intended mobile interface | Phosh (blocked on DRM/KMS and input bring-up) |
| Kernel strategy | downstream bring-up + separate mainline research |
| Target architecture | aarch64 |

## Pinned and verified inputs

The downstream candidate is recorded in `kernel-sources.json`:
- repository: `ravindu644/android_kernel_a042f`
- branch: `a04e`
- commit: `7c1b304f2df8df4c85abe6fe84b8238d7521bd58`
- kernel version: `4.19.191`
- device defconfig: `a04e_defconfig`

The uploaded running `/proc/config.gz` decompresses to 159,317 bytes and
has Git blob SHA-1
`c63ca74d9e6e595d215d12b735facf888c1eb151`, exactly matching the pinned
source's `a04e_defconfig`. This confirms the starting configuration, not
postmarketOS bootability.

The kernel source repository was archived on 2025-12-31. The kernel's
`README_Kernel.txt` documents Clang r383902 and an AArch64 GNU cross
compiler. The corresponding pinned ARM GNU 14.2 / Clang r383902 archives are
recorded in `toolchains.json`. Their release page does not publish fixed
checksums; the new CI records SHA-256 values for review.

## Hardware source investigation

- The device-specific DTS identifies `Samsung,A04e EUR OPEN 00` and includes
  the Samsung HS04 board DTS.
- The actual boot image was parsed: Android boot header v2, 2 KiB page size,
  12,061,530-byte gzip kernel payload and 1,412,010-byte gzip ramdisk.
- The actual DTBO was parsed: one 64,951-byte FDT overlay entry with matching
  A04e and MT6765 compatible strings.
- The downstream defconfig enables the vendor MTK framebuffer/LCM stack, but
  disables `CONFIG_DRM_MEDIATEK`, `CONFIG_MTK_LCM_DEVICE_TREE_SUPPORT` and
  `CONFIG_DEVTMPFS`.
- The HS04 source contains seven candidate 720x1600 panel drivers. The active
  physical panel variant is not yet identified.
- The HS04 touchscreen DTSI describes Chipone, Jadard and GalaxyCore SPI
  candidates. Runtime reports show `jadard-touchscreen`, but the exact
  populated controller and compatible binding still need confirmation.
- The inspected current upstream MediaTek DRM driver match table does not
  contain MT6765 MMSYS support.

Detailed source analysis: `DISPLAY-TOUCH-PORTING-ANALYSIS.md`.

## New implementation work

- Added `linux-samsung-a04e/APKBUILD` with the exact downstream source commit,
  documented toolchain versions, and a minimal initramfs/storage config
  fragment.
- Added `device-samsung-a04e/APKBUILD`, conservative deviceinfo and a
  minimal Linux kernel command line.
- Kept `deviceinfo_flash_method="none"` and `deviceinfo_drm="false"`.
- Added a GitHub Actions kernel compile workflow. It is a compile test, not a
  native boot test.
- Added `scripts/collect-panel-touch.sh` to collect runtime panel, input,
  device-tree and kernel-log evidence without writing partitions.

## Remaining engineering gates

1. Review the toolchain SHA-256 values emitted by CI and replace provisional
   `SKIP` source checksums with fixed hashes.
2. Get the first downstream kernel compile to pass; fix source/toolchain issues.
3. Build the APKBUILDs with pmbootstrap and validate the device package.
4. Identify the exact LCD panel and touchscreen controller from the new
   read-only handset report.
5. Establish a safe, independently verified Samsung recovery route.
6. Adapt or replace the legacy MediaTek display path with a working DRM/KMS
   driver; the existing vendor framebuffer alone is not Phosh support.
7. Produce a diagnostic initramfs and test native boot without touching
   Android data or persistent partitions.
8. Bring up display, touch, storage, USB, Wi-Fi, audio, battery and suspend.
9. Integrate Phosh only after a DRM/KMS display and input stack work.
10. Generate a postmarketOS image only after repeatable boot and recovery tests.

## Current truthful status

- Live defconfig match: verified.
- Boot header and DTBO structure: inspected successfully.
- HS04/A04e vendor display and touch source: inspected.
- Kernel and device APKBUILD scaffolding: committed; pmbootstrap build not yet
  verified.
- Reproducible toolchain versions: pinned; archive checksums pending review.
- Downstream kernel compilation: pending GitHub Actions result.
- Exact active panel: unresolved.
- Exact touchscreen controller: not fully resolved.
- Diagnostic initramfs/native boot: not yet produced/tested.
- DRM/KMS display and touchscreen on native Linux: not working/verified.
- Phosh: not integrated.
- postmarketOS image: not generated.
- Flash procedure: not verified; no partition writes.
