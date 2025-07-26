FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install all required packages
RUN apt update && \
    apt install -y gcc-aarch64-linux-gnu make git bison flex \
                   libssl-dev bc build-essential device-tree-compiler \
                   qemu-system-aarch64 libncurses-dev ca-certificates \
                   xz-utils wget cpio gzip fdisk kpartx util-linux \
                   dosfstools mount && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Clone and build U-Boot
WORKDIR /opt
RUN git clone https://source.denx.de/u-boot/u-boot.git
WORKDIR /opt/u-boot
RUN git checkout v2024.01 && \
    make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- qemu_arm64_defconfig && \
    sed -i 's|^CONFIG_BOOTCOMMAND=.*$|CONFIG_BOOTCOMMAND="ext4load virtio 0:1 0x40000000 /Image; ext4load virtio 0:1 0x43000000 /initramfs.cpio.gz; setenv bootargs '\''console=ttyAMA0'\''; booti 0x40000000 0x43000000:0x100000 $fdtcontroladdr"|g' .config && \
    make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- olddefconfig && \
    make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)

# Clone and build Linux kernel
WORKDIR /opt
RUN git clone --branch v5.10 --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git linux-5.10
WORKDIR /opt/linux-5.10
RUN make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean && \
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig && \
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)

# Copy init.c into the container
COPY init.c /opt/initramfs_dir/init.c

# Build initramfs
WORKDIR /opt/initramfs_dir
RUN aarch64-linux-gnu-gcc -static init.c -o init && \
    mkdir -p initramfs && \
    cp init initramfs/ && \
    cd initramfs && \
    find . | cpio -o --format=newc | gzip > ../initramfs.cpio.gz && \
    cd ..

# Copy and prepare the final run script
COPY setup_disk_and_run /opt/setup_disk_and_run
RUN chmod +x /opt/setup_disk_and_run

# Set working directory and entrypoint
WORKDIR /opt
ENTRYPOINT ["/opt/setup_disk_and_run"]