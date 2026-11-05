# A04e postmarketOS port overlay

This is the device-specific pmaports overlay for the Samsung Galaxy A04e
SM-A042F (a04e, MediaTek MT6765 / HS04).

## Build target and current scope

- Architecture: aarch64
- Distribution: postmarketOS edge (Alpine)
- Current CI target: minimal diagnostic rootfs/boot-image packaging (UI disabled)
- Kernel: reuse the verified Samsung 4.19.191 Image.gz artifact from workflow run
  41811886477; rebuild the device-tree outputs from the pinned source.
- Kernel source commit: 7c1b304f2df8df4c85abe6fe84b8238d7521bd58.

The workflow `.github/workflows/a04e-postmarketos-image.yml` attempts a real
pmbootstrap package/rootfs/boot-image build. A successful artifact is only a
bring-up candidate. It is not a finished graphical phone OS and is not approved
for flashing until all gates below pass.

## Display and touchscreen evidence

The user's runtime diagnostics identify:

- 720x1600 display using the legacy MediaTek `mtkfb` / LCM pipeline.
- Active Jadard touchscreen on SPI1.1 (`jadard,jdcommon`, driver
  `jadard_tp`, input `jadard-touchscreen`).
- The pinned kernel config enables `CONFIG_MTK_LCM`, `CONFIG_MTK_FB`, and
  the Jadard JD9365T driver family.
- The A04e device-tree overlay carries the board-specific panel and Jadard
  SPI touchscreen nodes.

This is driver/configuration evidence, not proof of a successful Linux boot.
The physical LCD variant among the HS04 candidate panels has not yet been
identified. The legacy framebuffer path is not a verified DRM/KMS path, so
Phosh is not yet a supported/validated interface. Touch input has not yet
been tested in a postmarketOS initramfs.

## Package layout

- `device/downstream/device-samsung-a04e`: device package and deviceinfo.
- `device/downstream/linux-samsung-a04e`: prebuilt-kernel package recipe,
  kernel config fragment and DTB merge steps.

The kernel package reuses the pinned Image.gz and must not silently compile a
different kernel. The image workflow downloads the existing artifact, verifies
its SHA-256, stages it for APKBUILD, and builds the DTB outputs from the pinned
source. The original kernel artifact expires on 2026-11-18 and must be
preserved or replaced with a verified durable artifact before then.

## Flash and recovery safety

- `deviceinfo_flash_method="heimdall-bootimg"` is packaging metadata only.
- The handset's raw boot/recovery partition nodes and capacities have been
  read-only inspected; PIT labels and Odin/Heimdall acceptance remain unverified.
- The user has made full-size boot and TWRP recovery backups and verified each
  backup SHA-256 against its source partition.
- Do not write to raw partitions or flash this image yet.
- Keep `flashable: false` and `verified_linux_boot: false` until a diagnostic
  boot, display, touch, and stock recovery test all pass.

## Required gates before calling the port usable

1. Identify the actual LCD panel variant and prove the selected LCM sequence.
2. Boot the diagnostic image without modifying Android data or recovery.
3. Verify that the framebuffer remains active after initramfs/userspace starts.
4. Verify Jadard SPI interrupts, reset, coordinate mapping and real touch events.
5. Validate storage, USB, Wi-Fi, audio, battery/charging and suspend/resume.
6. Port or validate DRM/KMS before enabling Phosh.
7. Verify the exact Samsung PIT/Download Mode flashing and stock restore route.

A green metadata check or successful image packaging job does not prove any of
these hardware gates. Publish no image as user-flashable until they pass.
