# A04e diagnostic findings

Sources: user-supplied read-only device report and running kernel config,
user-reported read-only partition/property output, and the user's successful
read-only boot/DTBO extraction and inspection. No partition contents have
been modified.

## Confirmed handset identity and platform

- Samsung Galaxy A04e, model `SM-A042F`, device/board `a04e`
- MediaTek `MT6765V/CB` / `mt6765`
- ARM64 userspace (`arm64-v8a`)
- Android 14 (SDK 34), vendor interface SDK 31 / VNDK 31
- Running kernel `4.19.191-28581296-abA042FXXSGEZF2`
- Device-tree compatible string observed: `mediatek,MT6765`
- User confirms the device uses an A-only partition layout. The empty
  `ro.boot.slot_suffix` alone was not treated as independent proof.

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

User-reported properties:

- `ro.boot.slot_suffix`: empty
- `ro.boot.flash.locked`: `0`
- `ro.boot.verifiedbootstate`: `orange`
- `ro.boot.vbmeta.device_state`: empty

The `flash.locked=0` property reports an unlocked bootloader state, and
`verifiedbootstate=orange` is consistent with that state. These are Android
boot properties, not independent bootloader-screen verification. The user
confirms the device's A-only layout; retain this as user-confirmed provenance.

## Read-only boot image inspection

The user copied the boot partition to shared storage with `dd if=...` and
inspected the saved image. Reported values:

- Source: `/dev/block/mmcblk0p37`
- Size: 33,554,432 bytes (32 MiB)
- SHA-256: `797db41a6d3cfe9056db60e841b852c76206b01d4715ff58331f2b8b9fc86a80`
- Android boot magic: `ANDROID!`
- Header version: 2
- Page size: 2,048 bytes
- Kernel payload: 12,061,530 bytes; begins with gzip magic
- Ramdisk payload: 1,412,010 bytes; begins with gzip magic
- Kernel load address: `0x40080000`
- Ramdisk load address: `0x51b00000`
- Boot command line: `bootopt=64S3,32N2,64N2 loop.max_part=7`

The extracted ramdisk listing contains Magisk integration files under
`.backup/.magisk` and `overlay.d/sbin/`. Treat this as a Magisk-integrated
boot ramdisk, not a clean manufacturer ramdisk.

## Read-only DTBO inspection

- Source: `/dev/block/mmcblk0p12`
- Size: 8,388,608 bytes (8 MiB)
- SHA-256: `79eb75c03bdca14444e49c991a50c19242b91de38910507412f7451c1e2c350d`
- Android DT table magic: `0xd7b7ab1e`
- Table total size: 65,015 bytes
- One overlay entry, size 64,951 bytes, offset 64
- Extracted overlay FDT magic: `0xd00dfeed`
- Compatible strings include `Samsung,A04e EUR OPEN 00` and
  `Mediatek,MT6765`

The overlay decompiled successfully. `dtc` emitted warnings related to
address-cell and unit-address conventions in the vendor overlay; these do
not invalidate the observed FDT magic or successful decompilation. The
overlay must be validated against its matching base tree before reuse.

## Display and input source findings

The device-specific source DTS includes the Samsung HS04 board DTS. The
downstream defconfig selects the HS04 project and enables:

- `CONFIG_MTK_FB=y`
- `CONFIG_MTK_LCM=y`
- Seven HS04 vendor LCM panel candidates, all in the 720x1600 family
- Generic `CONFIG_DRM=y` and `CONFIG_DRM_MIPI_DSI=y`
- `CONFIG_DRM_MEDIATEK` disabled
- `CONFIG_MTK_LCM_DEVICE_TREE_SUPPORT` disabled
- `CONFIG_DEVTMPFS` disabled

The HS04 touchscreen DTSI declares Chipone, Jadard and GalaxyCore SPI
candidates. The defconfig enables their vendor M04 options and Jadard JD9365T
support. This source does not by itself identify the exact panel or physical
touch controller installed in the user's handset.

The user's earlier runtime report lists input devices `mtk-tpd` and
`jadard-touchscreen`. These are useful clues but do not yet establish all
hardware bindings required by a native Linux port.

The inspected current upstream MediaTek DRM driver match table does not
contain an MT6765 MMSYS compatible. The vendor display implementation uses
MediaTek's private framebuffer/LCM/DDP stack and cannot be assumed to work
with a modern DRM/KMS compositor unchanged.

See `DISPLAY-TOUCH-PORTING-ANALYSIS.md` for source paths and detailed
display/touch findings.

## Remaining validation before an image can be called bootable

1. Establish the exact physical panel variant and its reset/power/timing data.
2. Establish the exact physical touch controller and Linux driver path.
3. Reproduce the downstream kernel build using a documented toolchain.
4. Build a postmarketOS kernel package and diagnostic initramfs.
5. Establish a safe, independently verified recovery route and boot test.

No partition writes are authorized by this porting work. No flashable image
has been produced or verified.
