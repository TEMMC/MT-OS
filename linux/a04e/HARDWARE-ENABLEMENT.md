# A04e hardware enablement audit

Target: Samsung Galaxy A04e SM-A042F / MediaTek MT6765 / HS04  
Kernel: Linux 4.19.191, ARM64  
Kernel source: `ravindu644/android_kernel_a042f` commit `7c1b304f2df8df4c85abe6fe84b8238d7521bd58`  
Connectivity source: `rsuntk-oss/mtk_connectivity_module` commit `3d48d43caa96b6f9be8a06199ee6eb2241d79153`  
Port branch: `linux/a04e-postmarketos-port`

This audit distinguishes source/configuration enablement from hardware proven
to work after a native postmarketOS boot. A Kconfig option or compiled driver
does not prove that the device binds, firmware loads, or userspace works.

## Enabled in the bring-up configuration

- **Boot/userspace discovery:** devtmpfs and devtmpfs mount, initramfs, tmpfs,
  ext4 and F2FS.
- **Display/touch:** MediaTek legacy framebuffer and LCM, MTK touchscreen,
  Jadard JD9365T/M04 driver options.
- **Battery/charging:** MT6357 battery/charger framework, MTK charger and
  power-off charging, plus the stock HS04 SGM41513 and UPM6910 charger drivers.
- **Connectivity:** MT6765 CONSYS_6765 / MT6631 / CONNAC selection.
- **Wi-Fi:** Gen4M WLAN, WMT common and adaptor sources are pinned for in-tree
  compilation with HIF=axi and WLAN_CHIP_ID=6765.
- **Bluetooth low-level transport:** MTK WMT/BTIF and connac1x driver sources
  are included in the connectivity build. This is not yet a verified BlueZ
  HCI adapter; standard Linux Bluetooth pairing is not claimed.
- **GPS/FM:** MTK combo GPS, GPS support and FM radio drivers are selected and
  included in the pinned connectivity source tree.
- **Audio:** MTK ASoC, MT6357 codec, audio routing/BT-CVSD options.
- **Other hardware:** eMMC, USB host/OTG/gadget, MTK sensors, thermal,
  PowerVR GPU support, camera sensor framework and CCCI/ECCCI modem transport.

The invalid `CONFIG_MTK_BATTERY` option was removed. The actual MT6357 and
charger Kconfig symbols are used. The external connectivity Kconfig's
`DRV_BUILD_IN` and reduced-connectivity-logging options are merged into the
pinned kernel source before configuration.

## Hardware-specific status and remaining blockers

| Feature | Current source/configuration | Still needed before calling it working |
|---|---|---|
| Display | Legacy MTK framebuffer/LCM and A04e DT overlay | Identify the exact physical LCD variant and prove panel hand-off. No verified MT6765 DRM/KMS path; Phosh remains blocked. |
| Touchscreen | Runtime report identifies Jadard; JD9365T/M04 options and matching board sources are enabled | Native boot test: verify IRQ, reset, input events and calibration. |
| Battery/charging | MT6357 framework plus SGM41513 and UPM6910 stock candidates | Confirm which charger IC binds on this handset and verify charging/current/temperature via power-supply sysfs. |
| Wi-Fi | MT6765 Gen4M source is pinned and scheduled for in-kernel compilation | Matching proprietary MT6631 firmware/config files must be extracted from the stock SM-A042F vendor image; then test scan, association and data. |
| Bluetooth | WMT/BTIF connac1x low-level source is included | A BlueZ HCI transport/adapter is not yet proven. Firmware, HCI enumeration, pairing and audio remain unverified. |
| GPS | MTK combo GPS driver source/config is included | Extract matching firmware/config, integrate a userspace GPS service and test fix/antenna. |
| FM radio | MTK FM driver source/config is included | Firmware, antenna path and a userspace radio application need testing. |
| Audio | MTK ASoC/MT6357 support is selected | Verify the A04e sound-card machine routing and test speaker, earpiece and microphone. |
| SIM/modem | CCCI/ECCCI and CLDMA transport are selected | Integrate a compatible modem manager/ofono path and verify SIM, registration, calls and SMS. |
| GPU | PowerVR kernel support is present in the vendor kernel | Matching userspace driver/firmware and acceleration tests are required; this is not DRM/KMS. |
| eMMC/storage | MTK eMMC, block and filesystem support are selected | Verify rootfs mount and read/write behavior during diagnostic boot. |
| USB/OTG | MTK USB host/OTG and gadget options are selected | Test host/device role switching, cable detection and a recovery console. |
| Sensors/thermal | MTK sensor hub and thermal options are selected | Test each physical sensor and thermal-zone reporting on native Linux. |
| Camera | MTK image-sensor framework is selected | Identify the exact camera modules and supply sensor tuning/firmware and userspace camera stack. |

## Firmware handling

No proprietary Samsung firmware blobs are committed or redistributed. The
MT6765 connectivity drivers need the matching stock vendor firmware/config
files. These must be extracted from the user's own SM-A042F stock vendor
partition and staged as a separate local firmware input before Wi-Fi, BT,
GPS or FM can be considered operational.

## Boot and installation safety

The device package describes Android boot header v2, 2048-byte pages and
Samsung BOOT-partition packaging through Heimdall. This is packaging metadata
only. The project remains `flashable: false` and has no verified native Linux
boot. Do not write BOOT, DTBO, vbmeta, recovery, super or userdata during this
bring-up.

## Validation gates

1. Complete the pinned Linux 4.19.191 build and verify Gen4M, WMT/BTIF, GPS
   and FM objects were compiled into the kernel.
2. Build the device/kernel APKBUILDs with pmbootstrap and verify the image
   consumes the exact matching kernel artifact.
3. Inspect the generated Android boot image and DTB; confirm image size and
   partition limits without flashing.
4. Extract matching stock firmware and stage it separately.
5. Establish a verified Samsung restore route, then perform a non-destructive
   diagnostic boot.
6. Validate display, touch, charging, storage, USB, Wi-Fi, Bluetooth HCI,
   audio, modem, GPS/FM, sensors and suspend/resume individually.
7. Integrate Phosh only after a working DRM/KMS display and input stack exist.

No feature is represented as working merely because its configuration is
enabled or its object compiles.
