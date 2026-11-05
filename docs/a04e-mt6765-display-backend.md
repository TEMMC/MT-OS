# Samsung Galaxy A04e MT6765 display-backend port

Status: investigation complete; no unsafe DRM enablement committed.

## Why Phoc cannot render yet

Phosh is configured in the postmarketOS image, but Phoc needs a DRM/KMS
device (or another backend it explicitly supports). The A04e downstream kernel
currently selects the Android vendor `mtkfb`/LCM stack. That stack exposes
the legacy framebuffer interface and is not a DRM/KMS device.

## Useful discovery in the pinned kernel source

The pinned kernel is
`ravindu644/android_kernel_a042f@7c1b304f2df8df4c85abe6fe84b8238d7521bd58`.
It contains a substantial MediaTek DRM implementation under
`drivers/gpu/drm/mediatek/`, including:

- `mtk_drm_drv.c` and atomic KMS/CRTC/plane code
- OVL, RDMA, WDMA and other display pipeline components
- `mtk_dsi.c` and `mtk_mipi_tx.c`
- DRM panel extension support and optional fbdev emulation

This is valuable reusable source. However, the driver's
`mtk_drm_of_ids[]` table only matches MT2701, MT2712, MT6779, MT8173,
MT6885, MT6873, MT6853, MT6877, MT6833 and MT6781. It has no MT6765 MMSYS
match. Its MMSYS driver-data and DDP path tables likewise have no MT6765
entry. The live A04e defconfig explicitly leaves `CONFIG_DRM_MEDIATEK`
unset.

Therefore, setting `CONFIG_DRM_MEDIATEK=y` or adding a made-up
`mediatek,mt6765-mmsys` compatible would not create a working display:
there is no correct MT6765 component topology, register routing data,
clock/power sequence, interrupt mapping or DSI pipeline definition in the
DRM driver's supported SoC tables.

## A04e-specific display evidence

The pinned A04e DTS includes `hs04.dts`. That board DTS describes the
legacy LCM panel interface (`mediatek,lcm-panel`), LCD reset GPIO PIO 45,
display PWM pinctrl states, and a fallback framebuffer description. The
fallback values in that DTS are explicitly documented for an FPGA/no-LK
scenario; they must not be used as production framebuffer memory settings.

The HS04 source lists seven candidate 720x1600 MIPI-DSI panels. They have
different lane counts, PLL rates and command sequences. The actual production
panel must be identified before its DSI timings or init sequence can be
selected. The stock vendor LCM callbacks are not DRM panel drivers and
cannot simply be attached to the upstream DRM DSI host.

## Implementation required before enabling DRM/KMS

1. Identify the physical panel using live stock LCM selection/logs and
   compare it with the seven HS04 candidate drivers and extracted Jadard
   firmware variants.
2. Derive MT6765 display pipeline topology from the exact HS04 vendor
   `ddp_path`, `ddp_mutex`, `ddp_clock`, `ddp_dsi`, MMSYS and clock
   source. Record register ranges, IRQs, clocks, power domains and routing.
3. Add MT6765-specific MMSYS driver data and component descriptions to the
   vendor DRM implementation, including safe OVL/RDMA/DSI path routing.
   Do not copy MT6779/MT6781 routing tables without register-level proof.
4. Add the matching MT6765 MMSYS/OVL/RDMA/DSI nodes and graph endpoints to
   the Linux device tree, with clocks, resets, power domains and interrupts.
5. Port the *identified* A04e LCM sequence to a DRM panel driver, including
   regulators, reset GPIO, DSI lane count, mode timings, backlight and
   suspend/resume.
6. Build with `CONFIG_DRM_MEDIATEK=y`, validate that `/dev/dri/card0`
   and a connected 720x1600 connector appear, then test modesetting with
   `modetest` before starting Phoc.
7. Only after DRM atomic modesetting, touch input and suspend/resume pass on
   the handset should the device package set `deviceinfo_drm="true"` and
   Phosh be considered usable.

## Safety decision

Do not enable the existing DRM driver for A04e yet, do not remove the working
vendor mtkfb path, and do not set `deviceinfo_drm="true"`. A wrong display
pipeline or panel sequence can leave the phone with a black screen and no
usable recovery display. Keep the current build diagnostic-only and
non-flashable while MT6765 support is developed and tested.
