# A04e diagnostic findings

Sources: user-supplied read-only `device-report.txt` (generated
2026-11-03 13:15:57), user-supplied running `/proc/config.gz`, and
user-reported read-only partition/property output. No partition contents
have been modified.

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

## Relevant observed partitions and sizes

The report maps these by-name symlinks; the user subsequently measured the
following block-device sizes with `blockdev --getsize64` (read-only):

| Partition | Block device | Reported size |
|---|---|---:|
| boot | `/dev/block/mmcblk0p37` | 33,554,432 bytes (32 MiB) |
| recovery | `/dev/block/mmcblk0p38` | 38,797,312 bytes (37 MiB) |
| dtbo | `/dev/block/mmcblk0p12` | 8,388,608 bytes (8 MiB) |
| vbmeta | `/dev/block/mmcblk0p13` | 65,536 bytes (64 KiB) |
| vbmeta_system | `/dev/block/mmcblk0p39` | 65,536 bytes (64 KiB) |
| vbmeta_vendor | `/dev/block/mmcblk0p40` | 65,536 bytes (64 KiB) |
 
The report also maps `super` to `/dev/block/mmcblk0p44` and `userdata`
to `/dev/block/mmcblk0p50`; their sizes were not measured in this command.

## Bootloader and verified boot properties

User-reported property output:

- `ro.boot.slot_suffix`: empty
- `ro.boot.flash.locked`: `0`
- `ro.boot.verifiedbootstate`: `orange`
- `ro.boot.vbmeta.device_state`: empty

The `flash.locked=0` property reports an unlocked bootloader state, and
`verifiedbootstate=orange` is consistent with that state. These are Android
boot properties, not an independent bootloader screen verification.
An empty slot suffix does **not** establish A-only partitioning or prove that
there is no slot mechanism.

## Read-only boot and DTBO dumps — acquired, not yet inspected

The user reports successfully copying the complete boot and DTBO partitions
to shared storage using `dd if=...` (read-only source access):

| Dump | Source partition | Size | SHA-256 |
|---|---|---:|---|
| `a04e-boot.img` | `mmcblk0p37` | 33,554,432 bytes | `797db41a6d3cfe9056db60e841b852c76206b01d4715ff58331f2b8b9fc86a80` |
| `a04e-dtbo.img` | `mmcblk0p12` | 8,388,608 bytes | `79eb75c03bdca14444e49c991a50c19242b91de38910507412f7451c1e2c350d` |

These checksums and sizes are user-reported command output. The image files
themselves have not yet been attached to this conversation or parsed. Do not
infer a boot image header version, ramdisk format, DTB location, or DTBO table
contents from the filenames or hashes alone.

## Display and input

- Touch input names: `mtk-tpd`, `jadard-touchscreen`
- GPU device compatible: `mediatek,doma`
- GPU kernel driver: `pvrsrvkm`
- Framebuffer: `mtkfb`
- DRM device nodes exist (`card0`, `renderD128`), but the report does not
  prove that a usable DRM/KMS display pipeline is available to Phoc/Phosh.

## Outstanding evidence required before a real boot image recipe

1. Parse boot/recovery image header metadata and extract/inspect DTB/DTBO.
2. Compare DTB/DTBO compatible strings and panel/touch bindings.
3. Independently verify bootloader unlock and safe recovery/download mode.
4. Test kernel build compatibility with a current postmarketOS Alpine toolchain.
5. Perform a diagnostic initramfs boot test before any rootfs or persistent
   partition write is considered.

No partition writes are authorized by this porting work. No flashable image
has been produced or verified.
