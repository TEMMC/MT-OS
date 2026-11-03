# A04e diagnostic findings

Sources: user-supplied read-only report `device-report.txt` (generated
2026-11-03 13:15:57) and user-supplied `/proc/config.gz` captured from the
running handset. Neither source contains partition contents.

## Confirmed handset identity and platform

- Samsung Galaxy A04e, model `SM-A042F`, device/board `a04e`
- MediaTek `MT6765V/CB` / `mt6765`
- ARM64 userspace (`arm64-v8a`)
- Android 14 (SDK 34), vendor interface SDK 31 / VNDK 31
- Running kernel `4.19.191-28581296-abA042FXXSGEZF2`
- Device-tree compatible string observed: `mediatek,MT6765`

## Running kernel configuration — exact match verified

The uploaded `a04e-running-kernel-config.gz` decompresses to a 159,317-byte
Linux/arm64 4.19.191 configuration. Its Git blob SHA-1 is:

`c63ca74d9e6e595d215d12b735facf888c1eb151`

The pinned downstream source
`ravindu644/android_kernel_a042f`, branch `a04e`, commit
`7c1b304f2df8df4c85abe6fe84b8238d7521bd58`, has the same blob SHA-1 for
`arch/arm64/configs/a04e_defconfig`.

**Result: the live running-kernel configuration and `a04e_defconfig` are
byte-for-byte identical.** This confirms the correct starting defconfig for
the downstream track. It does not prove that the kernel builds with a current
postmarketOS toolchain or boots postmarketOS userspace.

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

## Outstanding evidence required before a real boot image recipe

1. Read-only boot and recovery image header metadata and partition sizes.
2. DTB/DTBO extraction and compatible-string comparison.
3. Bootloader unlock state and verified recovery/download-mode procedure.
4. Kernel build compatibility with a current postmarketOS Alpine toolchain.
5. A diagnostic initramfs boot test before any rootfs or persistent partition
   write is considered.

No partition writes are authorized by this porting work. No flashable image
has been produced or verified.
