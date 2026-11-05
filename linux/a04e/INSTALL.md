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

The active Jadard identity is enough to target the correct controller family in the device tree, but the downstream Android driver's successful binding does not prove that the driver works in a postmarketOS boot. The exact LCD panel sequence and a Linux display stack are still unresolved. The current kernel package deliberately does not claim DRM/KMS support.

## Build status

The current preflight workflow validates manifests and package metadata. It is not a postmarketOS image build and a green result does not mean the phone boots. The exact successful kernel artifact from run `41811886477` is pinned by SHA-256 and SHA-512. Fetch it into the kernel package source directory before packaging with `linux/a04e/scripts/fetch-a04e-kernel-artifact.sh <path-to-linux-samsung-a04e/Image.gz>` (requires authenticated GitHub CLI access). The script verifies both digests and does not compile a new kernel. **Important:** the current Actions artifact expires on 2026-11-18; preserve it as a durable release asset or rebuild the same pinned artifact before that date. The kernel APKBUILD only generates/merges DTBs and packages the verified `Image.gz`.

Until an image build, boot-image inspection, diagnostic boot, display test, touch test, and stock recovery test all pass, this project remains research/bring-up and must not publish a user-flashable image.
