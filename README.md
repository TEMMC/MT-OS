# MT-OS

**MT-OS is an experimental postmarketOS port for the Samsung Galaxy A04e (SM-A042F).**  
The project brings native Linux to the A04e, with **postmarketOS edge** as the base distribution and **Phosh** as the intended mobile interface.

> **Development status: experimental bring-up.** CI has produced structurally validated `boot.img` and `super.img` images, but the image has not been runtime-tested on the handset. A successful build is not proof that the phone boots or that its hardware works. Do not treat current artifacts as a verified installation or flashable release.

## Project target

| Item | Target |
|---|---|
| Device | Samsung Galaxy A04e |
| Model | SM-A042F |
| Codename / board | `a04e` / Samsung HS04 |
| SoC | MediaTek MT6765 |
| CPU architecture | ARM64 / AArch64 |
| GPU | PowerVR Rogue GE8320 (MediaTek Doma) |
| Display | 720 × 1600 |
| Linux distribution | postmarketOS edge |
| Mobile interface | Phosh (Phoc compositor) |
| Kernel base | Downstream Linux 4.19.191 |
| Port branch | `linux/a04e-postmarketos-port` |

## What this project is

This repository contains the device-specific work needed to bring postmarketOS to the A04e: kernel and device configuration, hardware enablement, image packaging, diagnostics, and CI workflows.

It is **not** an Android launcher, a generic ARM64 image, or a claim that every Android hardware feature already works under Linux.

## Build outputs

The A04e image workflow is designed to package:

- `boot.img` — Android boot-header-v2 image containing the A04e Linux kernel and initramfs.
- `super.img` — Android dynamic-partition image containing the postmarketOS root filesystem in the `pmos_root` logical partition.

The current image pipeline performs structural checks including boot-image header and size validation, dynamic-partition metadata parsing, logical-partition unpack/round-trip comparison, and a read-only ext4 filesystem check.

These checks validate image structure, **not real-device operation**.

## Hardware enablement

The port includes or investigates support for the A04e's MediaTek platform and hardware, including:

- MediaTek MT6765 kernel and device-tree support.
- Display panel and legacy MediaTek framebuffer support.
- Jadard touchscreen controller support.
- Battery and charging drivers.
- MTK connectivity components for Wi-Fi, Bluetooth, GPS, and FM.
- The userspace services and firmware needed to bring up networking and other devices.

Driver configuration or successful compilation does not establish that a device works at runtime. Display/compositor, touchscreen, charging, Wi-Fi, Bluetooth, audio, modem/calls/SMS, camera, GPU acceleration, sensors, and suspend/resume still require handset testing. Proprietary firmware may also be required.

## Repository documentation

- [A04e port overview](linux/a04e/README.md)
- [Hardware enablement audit](linux/a04e/HARDWARE-ENABLEMENT.md)
- [Current build status](linux/a04e/BUILD-STATUS.md)
- [Installation and recovery safety](linux/a04e/INSTALL.md)
- [Display and touchscreen porting analysis](linux/a04e/DISPLAY-TOUCH-PORTING-ANALYSIS.md)

## Safety

**Do not flash current images to your phone yet.** The image artifacts are experimental and flashing compatibility has not been validated on the handset.

In particular, the current `super.img` replaces Android logical partitions such as `system`, `odm`, `product`, `system_ext`, and `vendor`. It does not include userdata or the GPT. Incorrect flashing or an unverified boot/vbmeta setup can leave the phone unbootable.

Before any device test, the exact partition mapping, bootloader state, recovery route, and stock restore procedure must be verified. Keep complete stock backups of the partitions that may be affected.

## Development and CI

The active A04e development branch is:

`linux/a04e-postmarketos-port`

[View MT-OS GitHub Actions](https://github.com/TEMMC/MT-OS/actions?query=branch%3Alinux%2Fa04e-postmarketos-port)

Contributions, hardware reports, and reproducible test results are welcome. Please distinguish clearly between source configuration, successful compilation, image packaging, and hardware functionality.
