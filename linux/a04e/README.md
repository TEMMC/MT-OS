# MT Linux — Samsung Galaxy A04e (a04e)

**Target:** Samsung Galaxy A04e, SM-A042F  
**SoC:** MediaTek MT6765 / HS04  
**Architecture:** ARM64  
**Status:** native Linux bring-up in progress — no verified native boot and no flashable release.

This is a device-specific postmarketOS port, not a generic ARM64 GSI. A Linux root filesystem alone cannot boot this handset; it needs the matching kernel, device tree, display/touch drivers, power and connectivity support, firmware and a tested recovery path.

## Current implementation

- Downstream Linux 4.19.191 source pinned to `ravindu644/android_kernel_a042f` commit `7c1b304f2df8df4c85abe6fe84b8238d7521bd58`.
- Stock A04e `a04e_defconfig` preserved and layered with a postmarketOS configuration fragment.
- KernelSU-Next submodule pinned and staged separately because GitHub source archives omit submodule contents.
- MT6765/MT6768 Linux 4.19 connectivity source pinned to `rsuntk-oss/mtk_connectivity_module` commit `3d48d43caa96b6f9be8a06199ee6eb2241d79153`.
- Connectivity build selects MT6765/CONSYS_6765, MT6631/CONNAC, Gen4M Wi-Fi, WMT/BTIF Bluetooth transport, GPS and FM.
- Kernel CI checks that the Gen4M, WMT/BTIF, GPS and FM objects are actually compiled.
- Image CI waits for the matching kernel run, verifies its artifact and configuration, then builds the postmarketOS device image.
- Android boot-header-v2 / 2048-byte Heimdall BOOT packaging metadata is configured. This is not a verified flashing procedure.

## Important hardware limitations

- Display uses the legacy MediaTek framebuffer/LCM path. A working MT6765 DRM/KMS path is not established, so Phosh is blocked.
- Jadard touchscreen driver options and the HS04 SPI node are included, but native touch events are not tested.
- MT6357 battery/charger support and SGM41513/UPM6910 charger candidates are enabled; charging is not yet tested on native Linux.
- Gen4M Wi-Fi source is included, but matching proprietary stock firmware must be extracted before Wi-Fi can be considered operational.
- Bluetooth WMT/BTIF low-level transport is included. A working BlueZ HCI adapter is not established.
- GPS, FM, audio, SIM/modem, camera, GPU acceleration, sensors and suspend/resume are not validated on native Linux.

See:
- [Hardware enablement audit](HARDWARE-ENABLEMENT.md)
- [Current build status](BUILD-STATUS.md)
- [Installation and recovery safety](INSTALL.md)
- [Display/touch porting analysis](DISPLAY-TOUCH-PORTING-ANALYSIS.md)

## Collect handset diagnostics

On the rooted A04e, copy `scripts/collect-a04e.sh` to Termux and run:

```sh
su -c sh ./collect-a04e.sh
```

For panel/touch evidence:

```sh
su -c sh ./collect-panel-touch.sh
```

These collectors are read-only. Review their reports for private values before sharing.

## Firmware

No proprietary Samsung firmware blobs are committed or redistributed. Matching MT6631/CONNAC firmware and configuration must be extracted from the user's own stock SM-A042F vendor image and staged separately.

## Safety and CI meaning

- No partition is written by the CI workflows.
- `device.json` remains `flashable: false`.
- A successful kernel compile proves compilation only.
- A successful postmarketOS image build proves packaging only.
- Neither result proves that the phone boots or that any hardware works.
- Do not flash BOOT, DTBO, vbmeta, recovery, super or userdata until the exact PIT mapping, stock restore route and diagnostic boot are independently verified.

[View A04e GitHub Actions](https://github.com/TEMMC/MT-OS/actions?query=branch%3Alinux%2Fa04e-postmarketos-port)
