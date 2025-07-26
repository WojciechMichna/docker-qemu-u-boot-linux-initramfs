# U-Boot + Linux 5.10 + Custom Initramfs in Docker + QEMU

This project provides a **Docker-based environment** that builds and runs:

- **U-Boot v2024.01**
- **Linux Kernel v5.10**
- A **custom `initramfs`** containing a single static binary (`init`)

It uses **QEMU** to emulate an AArch64 system and boot everything from a hand-crafted virtual disk image — all inside a Docker container.

---

## 💡 What You’ll Learn

This exercise is designed to help you understand:

- How **U-Boot**, **initramfs**, and the **Linux kernel** work together
- How to boot a Linux kernel using **U-Boot with an external disk image**
- How to build an **initramfs manually** using `cpio`
- How to boot a minimal Linux environment from **scratch**, without init systems or distros

---

## 🧱 Components

| Component     | Version    | Notes                                 |
|---------------|------------|---------------------------------------|
| U-Boot        | v2024.01   | Built from source                     |
| Linux Kernel  | v5.10      | Built from source                     |
| Initramfs     | Hand-packed with `cpio` | Contains only one static `init` binary |
| Disk Image    | Created from zero | Partitioned, formatted, and populated manually |

---

## 🚀 How to Build and Run

```bash
# Build the Docker image
docker build -t uboot-builder .

# Run the environment (requires --privileged for loop device support)
docker run --privileged --rm -it uboot-builder