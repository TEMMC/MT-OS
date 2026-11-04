# MT Linux — Samsung Galaxy A04e (a04e)

**Target:** Samsung Galaxy A04e, SM-A042F  
**Codename:** `a04e` (confirm exact board revision from the handset)  
**Initial OS target:** postmarketOS / Alpine Linux with Phosh  
**Status:** bring-up research only — **no flashable image exists yet**.

## Why this is a port, not a GSI

A standalone Linux phone OS needs a device-specific boot chain, kernel, device tree, display, touchscreen, storage, audio, Wi-Fi and power support. An ARM64 root filesystem alone is not a bootable phone OS. The handset currently reports an MT6765 platform, Android 12 vendor interface (VNDK 31), Android 14 system, and a 4.19.191 Samsung kernel. These facts are useful for identifying the hardware but do not prove mainline Linux support.

## Safety status

- No boot, recovery, vendor, vbmeta, DTBO or other partition is modified by this project.
- CI currently performs metadata and script validation only.
- Do not flash generic postmarketOS, Ubuntu Touch, NativOS or Android GSIs as if they were a verified A04e Linux port.
- Do not replace the Samsung kernel until a device-specific kernel and a tested recovery route exist.
- Back up personal data and the complete stock firmware before any future boot-chain experiments.

## Milestones

1. **Hardware inventory:** collect exact model/board/SoC, booted device-tree compatibility, kernel config, partition map, display/touch drivers and available DRM interfaces.
2. **Kernel feasibility:** identify a viable mainline MT6765 base, required downstream patches and bootloader hand-off requirements.
3. **Device tree:** create and validate the A04e mainline DTS/DTB and panel/touch descriptions.
4. **Early boot:** boot a diagnostic initramfs without touching Android data partitions.
5. **Core hardware:** validate display, touch, storage, USB, Wi-Fi, audio, battery/charging and suspend/resume.
6. **OS image:** integrate the working kernel/device package into a postmarketOS image.
7. **Release:** publish only after repeatable boot tests and a documented recovery procedure.

## Collect handset diagnostics

On the rooted A04e, copy `scripts/collect-a04e.sh` to Termux and run:

```sh
su -c sh ./collect-a04e.sh
```

The script is read-only and writes a report directory under shared Download storage. It does not collect IMEI, serial number, accounts, contacts or message data. Review the report before sharing it. Device-tree binary export is opt-in because it may contain device-specific identifiers:

```sh
su -c sh ./collect-a04e.sh --include-dtb
```

## Known source leads

- [A042F Samsung kernel source (archived)](https://github.com/ravindu644/android_kernel_a042f)
- [MT6765 A04e kernel source mirror](https://github.com/Shubhamvis98/android_kernel_samsung_mt6765)
- [postmarketOS porting documentation](https://wiki.postmarketos.org/wiki/Porting_to_a_new_device)
- [postmarketOS device package repository](https://gitlab.com/postmarketOS/pmaports)

These are research inputs, not proof that a mainline kernel or a working Linux port already exists.


### Identify the physical LCD and touchscreen

After collecting the standard inventory, run the second read-only collector:

```sh
su -c sh ./collect-panel-touch.sh
```

It records panel identifiers exposed by the running vendor kernel, touchscreen
input metadata, matching device-tree strings, and filtered display/touch kernel
log lines. Review `panel-touch-report.txt` for private values before sharing
it. This evidence is required because the HS04 source contains several
incompatible 720x1600 panel candidates; selecting one by resolution alone is
unsafe.

## CI meaning

The GitHub Actions workflow checks the device manifest and shell syntax. A green CI result means the project files pass those checks; it does **not** mean Linux boots on the phone.
