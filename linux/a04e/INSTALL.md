# Samsung Galaxy A04e installation and recovery status

Target: Samsung Galaxy A04e SM-A042F (a04e), MT6765, A-only layout.

## Packaging method

The device package uses postmarketOS `heimdall-bootimg` packaging:

- `deviceinfo_flash_method="heimdall-bootimg"`
- Samsung PIT partition name: `BOOT`
- Android boot image header: v2
- Page size: 2048 bytes
- Boot image generation is enabled by the device package.

This is a packaging configuration, not proof that flashing is safe or that the image boots. The project must not claim `flashable: true` until a real handset test and recovery test pass.

## Current known partition observations

The read-only inventory recorded these block nodes on the user's SM-A042F:

| Partition | Observed block node |
| --- | --- |
| boot | /dev/block/mmcblk0p37 |
| recovery | /dev/block/mmcblk0p38 |
| dtbo | /dev/block/mmcblk0p12 |
| vbmeta | /dev/block/mmcblk0p13 |
| super | /dev/block/mmcblk0p44 |
| userdata | /dev/block/mmcblk0p50 |

These Android block-node observations do not establish the Samsung PIT labels, exact partition capacities, bootloader acceptance rules, or a safe restore procedure. Do not write to raw block devices using these paths.

## Before any handset installation

1. Confirm OEM unlocking is available and the bootloader is actually unlocked.
2. Obtain and verify the complete matching SM-A042F stock firmware and a tested restoration path.
3. Read the device's PIT from Download Mode and confirm the boot partition name and capacity independently.
4. Verify the generated boot image header, kernel, ramdisk, DTB and image size.
5. Verify the exact Heimdall/Odin procedure on this model and firmware revision.
6. First attempt a non-destructive diagnostic boot if the bootloader supports it.
7. Only after recovery is proven should a boot-only installation be attempted.

Do not flash `super`, `userdata`, `vbmeta`, `dtbo`, or `recovery` as part of this bring-up. Do not use a generic scatter file, generic MTK DA package, or another A04e variant's PIT.

## Display and touch status

The 2026-11-05 runtime report confirms:

- 720x1600 output through the legacy MediaTek `mtkfb` framebuffer and DSI pipeline.
- A generic `mediatek,lcm-panel` device-tree binding, but no exact panel model or vendor initialization sequence.
- Active SPI touchscreen at `spi1.1`, compatible `jadard,jdcommon`, bound to `jadard_tp`, exposed as `jadard-touchscreen`.
- Chipone and GalaxyCore SPI nodes are also present, but they are not the active input device in this report.

The pinned kernel source and the previously successful kernel artifact have now been inspected directly. The artifact's saved `kernel.config` confirms:

- `CONFIG_MTK_LCM=y` and `CONFIG_MTK_FB=y`: the vendor MediaTek LCM/framebuffer display path is compiled in.
- `CONFIG_CUSTOM_KERNEL_LCM` includes the HS04 panel candidates: JD9365T TXD CTC, GC7202 LS HSD, NL9911C HLT HKC, JD9365T TXD BOE, NL9911C HR HR, JD9365T TXD CTC JBPD, and the HS04 default.
- `CONFIG_TOUCHSCREEN_JADARD_MODULE=y`, `CONFIG_TOUCHSCREEN_JADARD_IC_JD9365T=y`, `CONFIG_TOUCHSCREEN_JADARD_COMMON=y`, and `CONFIG_TOUCHSCREEN_JADARD_CHIPSET_M04=y`: the Jadard JD9365T driver family is compiled in.
- The HS04 device tree declares the Jadard controller on SPI1.1 with 720x1600 coordinates, 10 touch points, interrupt GPIO 10 and reset GPIO 172.

This is materially better than an unsupported generic kernel: the pinned kernel contains the correct vendor display and Jadard driver families, and the board DTS contains the matching SPI touch node. The kernel package now fails its build if these display/touch config options disappear.

**Still not proven:** which one of the seven LCD panel variants is physically installed/selected at runtime; whether the LK/bootloader hand-off selects the right LCM driver for a postmarketOS boot; whether the framebuffer remains active after Linux userspace starts; and whether touch events work in the postmarketOS initramfs. DRM/KMS is not enabled, so this is not yet a Phosh-capable graphics stack. The current image workflow is a diagnostic bring-up build, not a finished graphical Linux phone image.

## Build status

The current preflight workflow validates manifests and package metadata. It is not a postmarketOS image build and a green result does not mean the phone boots. The exact successful kernel artifact from run `41811886477` is pinned by SHA-256 and SHA-512. Fetch it into the kernel package source directory before packaging with `linux/a04e/scripts/fetch-a04e-kernel-artifact.sh <path-to-linux-samsung-a04e/Image.gz>` (requires authenticated GitHub CLI access). The script verifies both digests and does not compile a new kernel. **Important:** the current Actions artifact expires on 2026-11-18; preserve it as a durable release asset or rebuild the same pinned artifact before that date. The kernel APKBUILD only generates/merges DTBs and packages the verified `Image.gz`.

Until an image build, boot-image inspection, diagnostic boot, display test, touch test, and stock recovery test all pass, this project remains research/bring-up and must not publish a user-flashable image.
