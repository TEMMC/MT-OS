# Samsung Galaxy A04e installation and recovery status

Target: Samsung Galaxy A04e SM-A042F, MT6765 / HS04, ARM64.

**NOT VERIFIED FOR FLASHING**

The current work is a native Linux bring-up. There is no verified Linux boot on this handset and the device manifest deliberately remains `flashable: false`.

## Packaging method

The device package is configured for postmarketOS `heimdall-bootimg` packaging:

- Android boot image header v2
- Page size 2048 bytes
- Samsung PIT target label: `BOOT`
- Heimdall boot-image packaging

These settings describe how the build system packages a boot image. They do not prove that the image is accepted by the bootloader, that the PIT label/capacity is correct for every SM-A042F revision, or that flashing is safe.

## Previously observed partition nodes

The read-only inventory recorded these nodes on the handset:

| Partition | Observed block node |
| --- | --- |
| boot | `/dev/block/mmcblk0p37` |
| recovery | `/dev/block/mmcblk0p38` |
| dtbo | `/dev/block/mmcblk0p12` |
| vbmeta | `/dev/block/mmcblk0p13` |
| super | `/dev/block/mmcblk0p44` |
| userdata | `/dev/block/mmcblk0p50` |

These Android block-node observations do not establish Samsung PIT labels, exact capacities, bootloader acceptance rules or a safe restoration procedure. Never write raw partitions using these paths.

## Current kernel and hardware configuration

The build uses the pinned Samsung downstream Linux 4.19.191 source and the separate MT6765/MT6631 4.19 connectivity source.

The configuration includes:
- MTK legacy framebuffer/LCM and Jadard JD9365T/M04 touchscreen options.
- MT6357 battery/charger framework and SGM41513/UPM6910 charger candidates.
- MT6765 Gen4M Wi-Fi and WMT/BTIF Bluetooth transport source.
- MTK GPS and FM radio drivers.
- MTK ASoC/MT6357 audio, camera framework, modem transport, USB, eMMC, GPU, sensors and thermal options.

Important limitations:
- No verified DRM/KMS display path; Phosh is not ready.
- The physical LCD variant and native touch behavior remain untested.
- Matching stock MT6631/CONNAC firmware is not included.
- Bluetooth WMT/BTIF is not yet a proven BlueZ HCI adapter.
- Charging, audio, calls, SMS, GPS, FM, camera, GPU acceleration and suspend/resume have not been tested in native Linux.

See [HARDWARE-ENABLEMENT.md](HARDWARE-ENABLEMENT.md) for the detailed source audit and remaining tests.

## Before any handset installation

1. Confirm OEM unlocking is available and the bootloader is actually unlocked.
2. Obtain and verify the complete matching SM-A042F stock firmware.
3. Establish and test a complete stock restoration path.
4. Read the device PIT from Download Mode and independently confirm the BOOT partition label and capacity.
5. Inspect the generated boot image header, kernel, ramdisk, DTB and final size.
6. Confirm that the image was built using the exact matching kernel artifact.
7. Attempt a non-destructive diagnostic boot first, if the bootloader supports it.
8. Only after successful boot and recovery testing should a boot-only installation be considered.

Do not flash `super`, `userdata`, `vbmeta`, `dtbo` or `recovery` as part of this bring-up. Do not use a generic scatter file, generic MTK Download Agent package or another A04e variant's PIT.

## Current CI

The kernel workflow compiles the pinned kernel and checks that the MT6765 Gen4M, WMT/BTIF, GPS and FM object trees are built. The image workflow waits for that exact kernel run, verifies its artifact and then attempts postmarketOS packaging.

A green kernel workflow means the kernel compiled. A green image workflow means the image packaged. Neither means the handset boots, charges, connects to Wi-Fi, exposes a BlueZ adapter or is safe to flash.

[View A04e GitHub Actions](https://github.com/TEMMC/MT-OS/actions?query=branch%3Alinux%2Fa04e-postmarketos-port)
