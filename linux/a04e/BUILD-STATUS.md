# A04e native postmarketOS build status

## Selected build profile

| Setting | Selection |
|---|---|
| Build environment | GitHub Actions |
| Build system | pmbootstrap |
| Package repository format | pmaports / Alpine APKBUILD |
| Distribution target | postmarketOS edge |
| Mobile interface | Phosh |
| Kernel strategy | downstream bring-up + separate mainline track |
| Target architecture | aarch64 |

## What is pinned

The downstream candidate is recorded in `kernel-sources.json`:
- repository: `ravindu644/android_kernel_a042f`
- branch: `a04e`
- commit: `7c1b304f2df8df4c85abe6fe84b8238d7521bd58`
- kernel version: `4.19.191`
- device defconfig: `a04e_defconfig`

The repository is archived. Pinning it makes experiments reproducible; it
does not certify that it can build with current Alpine toolchains or boot
postmarketOS userspace.

## Build gates

1. Review handset diagnostics and verify boot/recovery/partition metadata.
2. Create the pmaports-style device package and conservative deviceinfo.
3. Create the downstream kernel APKBUILD, adapt the Android defconfig for
   postmarketOS requirements, and test compilation in pmbootstrap.
4. Produce a diagnostic initramfs and validate boot without modifying Android
   data or persistent partitions.
5. Bring up display and touchscreen before selecting Phosh as a usable UI.
6. Add the independent mainline kernel package and MT6765 device-tree work.
7. Generate and publish an image only after repeatable boot and recovery tests.

A successful GitHub Actions metadata check is not a kernel build or boot test.
A successful kernel compile is not proof that the phone can boot it.
