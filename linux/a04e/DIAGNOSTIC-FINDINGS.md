# A04e diagnostic findings

Source: user-supplied read-only report `device-report.txt`, generated
2026-11-03 13:15:57. The report does not contain partition contents.

## Confirmed handset identity and platform

- Samsung Galaxy A04e, model `SM-A042F`, device/board `a04e`
- MediaTek `MT6765V/CB` / `mt6765`
- ARM64 userspace (`arm64-v8a`)
- Android 14 (SDK 34), vendor interface SDK 31 / VNDK 31
- Running kernel `4.19.191-28581296-abA042FXXSGEZF2`
- Device-tree compatible string observed: `mediatek,MT6765`

## Relevant observed partitions

The report maps these by-name symlinks:

| Partition | Block device |
|---|---|
| boot | `/dev/block/mmcblk0p37` |
| recovery | `/dev/block/mmcblk0p38` |
| dtbo | `/dev/block/mmcblk0p12` |
| vbmeta | `/dev/block/mmcblk0p13` |
| vbmeta_system | `/dev/block/mmcblk0p39` |
| vbmeta_vendor | `/dev/block/mmcblk0p40` |
| super | `/dev/block/mmcblk0p44` |
| userdata | `/dev/block/mmcblk0p50` |

This is evidence of current by-name mappings only. The report contains no
partition sizes, raw image headers, bootloader environment, or proof of a
safe alternate boot path. Do not infer that the phone is A-only solely from
these names.

## Display and input

- Touch input names: `mtk-tpd`, `jadard-touchscreen`
- GPU device compatible: `mediatek,doma`
- GPU kernel driver: `pvrsrvkm`
- Framebuffer: `mtkfb`
- DRM device nodes exist (`card0`, `renderD128`), but the report does not
  prove that a usable DRM/KMS display pipeline is available to Phoc/Phosh.

## Kernel source candidate

The A042F downstream source contains both:
- `arch/arm64/configs/a04e_defconfig`
- `arch/arm64/configs/a04e_00_defconfig`

The full `a04e_defconfig` is the larger candidate (159317 bytes) and is
recorded as the initial source defconfig. The live report confirms the
kernel release but does not include the contents of `/proc/config.gz`;
therefore the source defconfig has not been verified as identical to the
running kernel configuration.

## Outstanding evidence required before a real boot image recipe

1. Read-only copy of `/proc/config.gz` (decompressed to `.config`).
2. Read-only boot and recovery image header metadata and partition sizes.
3. DTB/DTBO extraction and compatible-string comparison.
4. Bootloader unlock state and verified recovery/download-mode procedure.
5. Kernel build compatibility with a current postmarketOS Alpine toolchain.
6. A diagnostic initramfs boot test before any rootfs or persistent partition
   write is considered.

No partition writes are authorized by this porting work. No flashable image
has been produced or verified.
