# A04e hardware enablement audit

Target: Samsung Galaxy A04e SM-A042F / MT6765 / HS04  
Kernel source: `ravindu644/android_kernel_a042f` at `7c1b304f2df8df4c85abe6fe84b8238d7521bd58`  
Kernel: Linux 4.19.191, ARM64  
Port branch: `linux/a04e-postmarketos-port`

This audit distinguishes Kconfig/source enablement from hardware proven to work
after a native postmarketOS boot. A kernel option being enabled is not proof
that the driver binds, firmware is present, or the userspace stack works.

## Enabled or preserved in the A04e kernel configuration

- Device discovery: `CONFIG_DEVTMPFS=y`, `CONFIG_DEVTMPFS_MOUNT=y`.
- Root filesystems: initramfs, tmpfs, ext4 and F2FS.
- Display hand-off: vendor MediaTek `CONFIG_MTK_FB=y` and `CONFIG_MTK_LCM=y`.
- Touch: `CONFIG_TOUCHSCREEN_MTK=y` and Jadard JD9365T/M04 driver options.
- Battery/charging: `CONFIG_POWER_SUPPLY=y`, `CONFIG_BATTERY_MT6357=y`,
  `CONFIG_CHARGER_TYPE_MT6357=y`, `CONFIG_MTK_CHARGER=y`, and
  `CONFIG_MTK_KERNEL_POWER_OFF_CHARGING=y`.
- Bluetooth protocol layer: BlueZ RFCOMM, BNEP and HIDP plus MT6765 combo
  communication/BlueZ HCI Kconfig options.
- Combo connectivity: MT6765 CONSYS selection and MTK combo Wi-Fi Kconfig.
- eMMC/storage, USB OTG/host, MediaTek sensors, thermal management, GPU
  driver support, audio SoC framework and CCCI/ECCCI modem transport remain
  selected by the matching stock A04e defconfig and are checked in APKBUILD.

The nonexistent `CONFIG_MTK_BATTERY` option was removed. The actual battery
and charger Kconfig symbols from this kernel tree are checked instead.

## Device-specific findings and remaining blockers

| Feature | Source/configuration status | What is still required |
|---|---|---|
| Display | Legacy MTK framebuffer/LCM and A04e DT overlay | Identify exact LCD variant and prove the bootloader-to-kernel panel hand-off. There is no verified MT6765 DRM/KMS path; Phosh is blocked. |
| Touchscreen | Runtime report identifies Jadard at SPI1.1; matching DT node and JD9365T/M04 driver options are enabled | Boot the diagnostic initramfs and verify real touch events, IRQ and reset behavior. |
| Battery/charging | MT6357 battery/charger framework and stock charger candidates are enabled | Confirm the actual charger IC binding and inspect power-supply sysfs while charging on native Linux. |
| Wi-Fi | MT6765 combo Wi-Fi Kconfig is selected | The kernel Makefile expects external `vendor/mediatek/kernel_modules/connectivity/wlan/core/gen4m` sources and the matching WMT/WLAN adaptor. These are not part of the pinned kernel source archive. Obtain and pin matching vendor modules and firmware before Wi-Fi can work. |
| Bluetooth | BlueZ protocol options and MTK combo HCI Kconfig are selected | Verify/package the matching MTK WMT/BT transport implementation and firmware; test HCI enumeration and pairing. Kconfig alone does not provide firmware. |
| Audio | MTK ASoC/MT6357 codec support is present in stock defconfig | Add/verify the A04e sound-card machine routing and userspace audio policy; test speaker, earpiece and microphone. |
| SIM/modem | CCCI/ECCCI and CLDMA transport are enabled in stock defconfig | Integrate and test a compatible modem manager/ofono interface and voice/SMS control protocol. Kernel transport enablement is not a working phone stack. |
| GPU | MTK PowerVR kernel support is present in the vendor kernel | Supply matching PowerVR userspace components and validate acceleration. This is not DRM/KMS and does not unblock Phosh. |
| eMMC/storage | MTK eMMC and block/filesystem support are present | Validate rootfs mount and read/write behavior in the diagnostic boot. |
| USB/OTG | MTK USB host/OTG and gadget support are present | Validate host/device role switching, cable detection and adb/serial recovery path. |
| Sensors/thermal | MTK sensor hub and MTK thermal support are present | Validate each physical sensor and thermal-zone reporting on the native boot. |
| Camera | MTK image-sensor framework is present | Identify the exact camera modules and provide matching sensor tuning/firmware and userspace camera stack. |

## Boot and installation safety

The device package describes Android boot header v2 and 2048-byte pages and
packages for the Samsung BOOT partition. This is packaging metadata only.
The project remains `flashable: false` until the generated image, exact PIT
mapping, bootloader behavior, full stock restore and diagnostic boot are
verified on the handset. Do not write BOOT, DTBO, vbmeta, recovery, super or
userdata during this bring-up.

## Validation gates

1. Kernel build with the postmarketOS config fragment passes and its artifact
   contains the updated `.config`.
2. The image workflow consumes that exact new kernel artifact, not the older
   stock-config artifact.
3. Device and kernel APKBUILDs pass pmbootstrap package validation.
4. Build and inspect the generated Android boot image; verify size and DTB.
5. Prove a stock restore route, then perform a non-destructive diagnostic boot.
6. Validate display, touch, charging, storage, USB, Wi-Fi, Bluetooth, audio,
   modem, sensors and suspend/resume individually.
7. Integrate Phosh only after a working DRM/KMS display and input stack exist.

No feature in the "remaining required" column is represented as working merely
because a Kconfig symbol is selected.
