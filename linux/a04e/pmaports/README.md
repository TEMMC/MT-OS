# A04e postmarketOS port overlay

This directory is the MT-OS working overlay for a future contribution to
postmarketOS `pmaports`. It follows the upstream split between:

- `device-samsung-a04e`: device package, `APKBUILD`, and `deviceinfo`
- `linux-samsung-a04e`: kernel package, config fragments, and patches

## Build target

- Architecture: `aarch64`
- Distribution: postmarketOS edge (Alpine)
- UI: Phosh
- Build engine: `pmbootstrap`
- Package recipes: Alpine `APKBUILD` recipes, using the pmaports conventions

## Kernel tracks

The downstream candidate is pinned in `../kernel-sources.json` to the
archived A042F Samsung kernel repository and its `a04e` branch commit.
Its reported kernel base is 4.19.191 and its device defconfig is
`a04e_defconfig`. This is a research input only. It has not yet been
converted into a verified postmarketOS kernel package.

The mainline track is kept separate. It must not inherit vendor-kernel
boot assumptions, patches, or configuration. A mainline port needs a
working MT6765 device tree, clocks, regulators, pinctrl, storage, display,
touch and bootloader hand-off support.

## Why the APKBUILD/deviceinfo are not fabricated yet

The current handset evidence does not establish the exact boot image format,
DTB/DTBO handling, partition names, panel/touch binding, or safe recovery
procedure. Those values control the device package and boot-deploy behavior.
Inventing them could create an image that looks complete but cannot boot, or
could direct a future flashing step at the wrong partition.

The next valid step is to collect and review the A04e diagnostic report,
then add the device package and downstream kernel package with real values.
Only after that should CI run `pmbootstrap build`, `pmbootstrap install`,
and `pmbootstrap export`.

## Current status

No device package, bootable kernel, generated postmarketOS image, or verified
flash procedure exists yet. The branch is not flashable.
