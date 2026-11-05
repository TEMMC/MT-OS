# A04e native postmarketOS build status

## Selected build profile

| Setting | Selection |
|---|---|
| Build environment | GitHub Actions |
| Build system | pmbootstrap / Alpine APKBUILD |
| Distribution target | postmarketOS edge |
| Intended mobile interface | Phosh (now selected in the image build; runtime blocked on display backend) |
| Kernel strategy | downstream Linux 4.19.191 with a separate mainline research path |
| Target architecture | aarch64 |
| Port branch | `linux/a04e-postmarketos-port` |

## Pinned sources and toolchains

The downstream kernel is pinned in `kernel-sources.json`:
- repository: `ravindu644/android_kernel_a042f`
- commit: `7c1b304f2df8df4c85abe6fe84b8238d7521bd58`
- kernel version: `4.19.191`
- defconfig: `a04e_defconfig`

The matching vendor connectivity source is pinned separately:
- repository: `rsuntk-oss/mtk_connectivity_module`
- ref: `staging-4.19`
- commit: `3d48d43caa96b6f9be8a06199ee6eb2241d79153`
- target: MT6765 / CONSYS_6765 / MT6631 / CONNAC
- build mode: `CONFIG_DRV_BUILD_IN=y`

Its README explicitly lists MT6765/MT6768 and Linux 4.19.x support. Its
Makefile selects Gen4M WLAN, HIF=axi, WLAN_CHIP_ID=6765, WMT/BTIF,
connac1x Bluetooth WMT, GPS and FM. The kernel build stages this source into
the kernel's in-tree connectivity directory and merges the vendor
`DRV_BUILD_IN`/logging Kconfig options without discarding the original
kernel connectivity symbols.

The kernel source requires the KernelSU-Next git submodule at commit
`56c55b692a00d90c0568a57ef5a8ed0daa23bb9a`; the source archive omits
submodule contents, so CI fetches and stages that exact commit separately.
Clang r383902 and AArch64 GNU 14.2 are pinned in `toolchains.json`; CI
records archive hashes for review.

## Hardware source investigation

- Device target: Samsung Galaxy A04e SM-A042F, MT6765, HS04.
- Device-specific DTS identifies Samsung A04e EUR OPEN 00 and the HS04 board.
- Runtime reports identify the Jadard touchscreen path; the exact physical
  panel and populated touch-controller variant still require native testing.
- HS04 charger DTS includes SGM41513 and UPM6910 candidates; both corresponding
  kernel drivers are preserved/enabled. The actual fitted IC must be verified.
- The vendor kernel uses legacy MTK framebuffer/LCM, not a verified DRM/KMS
  display path. Phosh remains blocked.
- The MT6765 combo source is separate from the kernel archive; it is now
  pinned and included in the kernel build workflow.
- Matching proprietary firmware is not included. It must be extracted from
  the user's own stock SM-A042F vendor image.

Detailed display/touch source analysis remains in
`DISPLAY-TOUCH-PORTING-ANALYSIS.md`.

## Implementation work committed

- Added kernel and device APKBUILDs, a conservative deviceinfo profile and
  minimal Linux kernel command line.
- Configured Android boot-header-v2 / 2048-byte packaging for the Samsung
  BOOT partition through Heimdall. This is packaging metadata only;
  `deviceinfo_drm="false"` and `flashable: false` remain intentional.
- Added devtmpfs/initramfs, storage, display, Jadard touch, MT6357 battery/
  charger, SGM41513/UPM6910, audio, camera, modem, GPU, USB, sensors and
  thermal configuration checks.
- Enabled the MT6765 combo options for Gen4M Wi-Fi, Bluetooth WMT/BTIF,
  GPS and FM.
- Corrected the Alpine APKBUILD environment by adding GNU coreutils for
  `readlink -m` used by the kernel config merge script.
- Changed the image workflow to wait for the matching kernel build artifact,
  verify its SHA-256 and kernel configuration, and stage that exact Image.gz.
- Added build-time checks that the Gen4M WLAN, WMT/BTIF, GPS and FM object
  trees were compiled.

## Current truthful status

- Source pins and device safety metadata: committed.
- Kernel configuration merge: previous run reached configuration; the
  current MT6765 connectivity build is queued/running in GitHub Actions.
- Full kernel compile with the pinned MT6765 connectivity tree: pending
  successful CI completion.
- pmbootstrap device/kernel package build: pending the matching kernel
  artifact. The image workflow now selects `ui=phosh` and adds ModemManager,
  NetworkManager and iio-sensor-proxy OpenRC services.
- Diagnostic image: an earlier image artifact exists but used the previous
  kernel/configuration; it is not accepted as the current image.
- Exact physical panel: unresolved.
- Native touchscreen, charging and display: not yet boot-tested.
- Wi-Fi: vendor Gen4M driver source is included in the current build; stock
  firmware extraction and on-device scan/association tests remain.
- Bluetooth: WMT/BTIF low-level transport is included; a working BlueZ HCI
  adapter is not established.
- GPS/FM, audio, SIM/modem, GPU acceleration, camera and sensors: not
  validated on native Linux.
- Phosh integration: configured in the postmarketOS image build; package/rootfs
  installation is pending CI. This is packaging integration, not proof that
  Phosh can start on the handset.
- Phoc display backend: not verified. The current downstream kernel exposes
  legacy MTK framebuffer/LCM, while the device has no validated DRM/KMS driver.
  Phoc/Phosh therefore remain expected not to render until a compatible
  compositor backend or DRM/KMS port is available.
- Native Linux boot: not verified.
- Flash procedure: not verified; no partition writes are authorized.

Do not treat a successful kernel compile or image packaging job as proof of
a bootable or fully working phone port.
