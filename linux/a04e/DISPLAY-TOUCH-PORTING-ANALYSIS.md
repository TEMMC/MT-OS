# A04e display and touchscreen source analysis

Inspection date: 2026-11-04

## Source revision

The analysis uses the pinned downstream kernel source:

- Repository: https://github.com/ravindu644/android_kernel_a042f
- Branch: `a04e`
- Commit: `7c1b304f2df8df4c85abe6fe84b8238d7521bd58`
- Defconfig: `arch/arm64/configs/a04e_defconfig`

The user's live `/proc/config.gz` was previously verified byte-for-byte identical to this defconfig.

## Board identity and device tree

The device-specific DTS,
`arch/arm64/boot/dts/mediatek/mt6765_a04e_eur_open_00.dts`,
includes:

- `../mediatek/hs04.dts`
- `mt6765-a04e_common.dtsi`

Its compatible string is `Samsung,A04e EUR OPEN 00`, `Mediatek,MT6765`.
The base board DTS is therefore the Samsung HS04 platform, not merely a
generic MT6765 reference.

The user's extracted DTBO has the same A04e and MT6765 compatible strings.
It is a valid FDT overlay. The overlay contains hardware fragments for the
panel, touch controller, DSI synchronization, I2C peripherals and storage.

## Display source findings

The HS04 base DTS defines a vendor LCM panel node:

- compatible: `mediatek,lcm-panel`
- LCD reset GPIO: PIO 45
- touchscreen reset GPIO: PIO 172
- display PWM pinctrl states: `disp_pwm`, `disp_pwm_gpio`

New live runtime evidence from the handset's `/sys/firmware/devicetree/base/chosen`
reports:

- `atag,videolfb-lcmname`: `nt35695B_fhd_dsi_cmd_auo_rt5081_drv`
- `atag,videolfb-islcmfound`: `1`
- `atag,videolfb-islcm_inited`: `0`

This is stronger than relying on the static fallback property in the source DTS:
the running bootloader reports this LCM name and says it found the panel. The
`islcm_inited=0` flag means we must not claim that the bootloader initialized it.
The handset also reports a 720x1600 active framebuffer mode, and TWRP
`3.7.1-12-citty2029` has working display and touch. Use the reported LCM name as
the leading source-search target, but verify the actual DSI mode, panel sequence,
resets, bias rails and backlight before implementing a Linux DRM panel driver.
Do not infer 1080p timings from the `fhd` substring in the identifier.

The exact A04e defconfig selects the HS04 project and enables the legacy
MediaTek LCM/framebuffer stack:

- `CONFIG_ARCH_MTK_PROJECT="hs04"`
- `CONFIG_MTK_LCM=y`
- `CONFIG_MTK_FB=y`
- `CONFIG_MTK_LCM_DEVICE_TREE_SUPPORT` is disabled
- `CONFIG_CUSTOM_KERNEL_LCM` lists seven HS04 panel candidates:
  - `lcd_jd9365t_txd_ctc_mipi_hdp_video`
  - `lcd_gc7202_ls_hsd_mipi_hdp_video`
  - `lcd_nl9911c_hlt_hkc_mipi_hdp_video`
  - `lcd_jd9365t_txd_boe_mipi_hdp_video`
  - `lcd_nl9911c_hr_hr_mipi_hdp_video`
  - `lcd_jd9365t_txd_ctc_jbpd_mipi_hdp_video`
  - `hs04_hdplus1600_dsi_default_vdo`

The candidate panel drivers describe 720x1600 MIPI-DSI panels, but they do
not all use the same DSI lane count, timing values or PLL clock. For example,
the inspected JD9365T CTC driver uses three lanes and a 572 MHz PLL setting,
whereas the GC7202 driver uses four lanes and a 276 MHz PLL setting. Therefore
choosing a panel by resolution alone would be unsafe.

The vendor panel drivers use MediaTek's private LCM callbacks
(`LCM_UTIL_FUNCS`, DSI command queue helpers, vendor GPIO/pinctrl helpers).
They are not drop-in Linux DRM panel drivers. The vendor display path is
implemented under:

- `drivers/misc/mediatek/video/mt6765/dispsys/`
- `drivers/misc/mediatek/video/mt6765/videox/`
- `drivers/misc/mediatek/lcm/`

The exact defconfig has generic DRM and MIPI-DSI core enabled, but
`CONFIG_DRM_MEDIATEK` is disabled. It also has `CONFIG_DEVTMPFS` disabled.
The current upstream Linux `drivers/gpu/drm/mediatek/mtk_drm_drv.c` SoC
match table inspected on 2026-11-04 does not contain an MT6765 MMSYS
compatible. This means a standard upstream MediaTek DRM/KMS driver cannot
currently be assumed to bind to this SoC without additional driver and
device-tree work.

## Touchscreen source findings

`arch/arm64/boot/dts/mediatek/hs04/hs04-touchscreen.dtsi` declares three
SPI touchscreen candidates:

- Chipone TDDI at SPI1 chip-select 0, compatible `chipone-tddi`
- Jadard at SPI1 chip-select 1, compatible `jadard,jdcommon`, configured
  for 720x1600 and up to ten touch points
- GalaxyCore at SPI1 chip-select 2, compatible `gcore,touchscreen`

The A04e defconfig enables the corresponding vendor M04 Jadard, GalaxyCore
and Chipone driver options, and also selects Jadard JD9365T support. These
are compiled/configured candidate drivers; the source configuration alone
does not prove which physical controller is populated in this handset.

The user's runtime diagnostics previously reported input devices named
`jadard-touchscreen` and `mtk-tpd`, with the active SPI1.1 node identified as
`jadard,jdcommon` and bound to `jadard_tp`. TWRP `3.7.1-12-citty2029` also has
working touchscreen input. This proves that the recovery environment can use
the handset's touch hardware; it does not prove that the postmarketOS kernel,
its SPI resources, IRQ/reset configuration or userspace input stack work.

## Consequences for the port

1. Keep the downstream kernel track as the first bring-up path. Its exact
   stock configuration and board-specific source are known.
2. Do not copy the vendor LCM driver directly into a modern kernel. Extract
   the panel command sequence, reset/power rails, DSI lane/timing parameters
   and backlight behavior, then implement or adapt a DRM panel driver.
3. Determine the exact panel variant before choosing a panel timing or
   initialization sequence.
4. Determine the actual touch controller and port/adapt its driver separately.
5. Keep the mainline track independent. MT6765 display-controller support,
   MMSYS topology, clocks, DSI host, panel and device tree need explicit
   validation.
6. A framebuffer console or early display test is not equivalent to a working
   DRM/KMS device. Phosh should not be marked usable until a compositor can
   obtain a real DRM/KMS display and input devices.

## Current confidence

- HS04 board family and A04e DTS: source-confirmed.
- A04e/MT6765 DTBO identity: confirmed from the user's extracted overlay.
- Vendor display implementation and panel candidate list: source-confirmed.
- Bootloader-reported LCM identifier: `nt35695B_fhd_dsi_cmd_auo_rt5081_drv`, with `lcmfound=1` and `lcm_inited=0`.
- Physical panel timing/init sequence: still requires correlation with the vendor source; active mode is 720x1600.
- TWRP 3.7.1-12-citty2029 display and touchscreen: working in recovery; native Linux display/touch remain untested.
- Exact physical touch controller: runtime points to Jadard on SPI1.1; native Linux binding remains untested.
- Upstream MT6765 DRM/KMS support: not present in the inspected current
  upstream MediaTek DRM match table.
- Native postmarketOS boot, DRM/KMS display, Phosh and touchscreen: not yet
  built or tested.

## Source links

- [A04e DTS](https://github.com/ravindu644/android_kernel_a042f/blob/7c1b304f2df8df4c85abe6fe84b8238d7521bd58/arch/arm64/boot/dts/mediatek/mt6765_a04e_eur_open_00.dts)
- [HS04 base DTS](https://github.com/ravindu644/android_kernel_a042f/blob/7c1b304f2df8df4c85abe6fe84b8238d7521bd58/arch/arm64/boot/dts/mediatek/hs04.dts)
- [HS04 touchscreen DTSI](https://github.com/ravindu644/android_kernel_a042f/blob/7c1b304f2df8df4c85abe6fe84b8238d7521bd58/arch/arm64/boot/dts/mediatek/hs04/hs04-touchscreen.dtsi)
- [A04e defconfig](https://github.com/ravindu644/android_kernel_a042f/blob/7c1b304f2df8df4c85abe6fe84b8238d7521bd58/arch/arm64/configs/a04e_defconfig)
- [HS04 LCM driver list](https://github.com/ravindu644/android_kernel_a042f/blob/7c1b304f2df8df4c85abe6fe84b8238d7521bd58/drivers/misc/mediatek/lcm/mt65xx_lcm_list.c)
- [HS04 vendor display stack](https://github.com/ravindu644/android_kernel_a042f/tree/7c1b304f2df8df4c85abe6fe84b8238d7521bd58/drivers/misc/mediatek/video/mt6765)
- [Upstream MediaTek DRM driver](https://github.com/torvalds/linux/blob/master/drivers/gpu/drm/mediatek/mtk_drm_drv.c)
