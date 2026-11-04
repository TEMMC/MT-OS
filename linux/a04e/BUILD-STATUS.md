# A04e native postmarketOS build status

## Selected build profile

| Setting | Selection |
|---|---|
| Build environment | GitHub Actions |
| Build system | pmbootstrap |
| Package repository format | pmaports / Alpine APKBUILD |
| Distribution target | postmarketOS edge |
| Mobile interface | Phosh |
| Kernel strategy | downstream bring-up + separate mainline track |
| Target architecture | aarch64 |

## What is pinned and verified

The downstream candidate is recorded in `kernel-sources.json`:
- repository: `ravindu644/android_kernel_a042f`
- branch: `a04e`
- commit: `7c1b304f2df8df4c85abe6fe84b8238d7521bd58`
- kernel version: `4.19.191`
- device defconfig: `a04e_defconfig`

**Live configuration verification passed:** the user's uploaded running
`/proc/config.gz` decompresses to 159,317 bytes and has Git blob SHA-1
`c63ca74d9e6e595d215d12b735facf888c1eb151`, exactly matching the pinned
source's `a04e_defconfig`. The correct downstream starting configuration is
therefore established.

The repository is archived. Pinning it makes experiments reproducible; the
config match does not certify compatibility with current Alpine toolchains or
postmarketOS bootability.

## Hardware source investigation

- The device-specific DTS identifies `Samsung,A04e EUR OPEN 00` and includes
  the Samsung HS04 board DTS.
- The user's actual boot image was parsed: Android boot header v2, 2 KiB page
  size, 12,061,530-byte gzip kernel payload and 1,412,010-byte gzip ramdisk.
- The user's actual DTBO was parsed: one 64,951-byte FDT overlay entry, with
  matching A04e and MT6765 compatible strings.
- The downstream defconfig enables the vendor MTK framebuffer/LCM stack, but
  disables `CONFIG_DRM_MEDIATEK`, `CONFIG_MTK_LCM_DEVICE_TREE_SUPPORT` and
  `CONFIG_DEVTMPFS`.
- The HS04 source contains seven candidate 720x1600 panel drivers. The
  active physical panel variant is not yet identified.
- The HS04 touchscreen DTSI describes Chipone, Jadard and GalaxyCore SPI
  candidates. The exact populated controller still needs confirmation.
- The inspected current upstream MediaTek DRM driver match table does not
  contain MT6765 MMSYS support.

Detailed source analysis: `DISPLAY-TOUCH-PORTING-ANALYSIS.md`.

## Build gates

1. Complete read-only validation of boot/recovery/partition metadata and
   establish a safe recovery path.
2. Create the pmaports-style device package and conservative deviceinfo.
3. Create the downstream kernel APKBUILD, adapt the Android kernel source for
   postmarketOS requirements, and test compilation in pmbootstrap.
4. Produce a diagnostic initramfs and validate boot without modifying Android
   data or persistent partitions.
5. Identify the exact display panel and touchscreen controller; bring up
   display and input before selecting Phosh as a usable UI.
6. Add the independent mainline kernel package and MT6765 device-tree work.
7. Generate and publish an image only after repeatable boot and recovery tests.

A successful GitHub Actions metadata check is not a kernel build or boot test.
A successful kernel compile is not proof that the phone can boot postmarketOS.

## Current truthful status

- Live defconfig match: verified.
- Boot header and DTBO structure: inspected successfully.
- HS04/A04e vendor display and touch source: inspected.
- Exact active panel and touch-controller variants: unresolved.
- Kernel compilation: not yet verified in the postmarketOS build pipeline.
- A04e pmaports device package: not yet created.
- Bootable kernel/initramfs: not yet produced.
- postmarketOS image: not yet produced.
- Flash procedure: not verified; no partition writes.
