#!/bin/bash

BOOTSECTOR="bootsector.asm"
DISK="disk.img"
ISO="LukOS.iso"

nasm -f bin "${BOOTSECTOR}" -o bootsector.bin # Assembles

dd if=/dev/zero of="${DISK}" bs=512 count=2880 # Makes blank 1.44MB disk
dd if=bootsector.bin of="${DISK}" bs=512 count=1 conv=notrunc # Copies bootsector to first 512B of disk

qemu-system-x86_64 -drive format=raw,file="${DISK}"

mkisofs -o "${ISO}" -b "${DISK}" ./"${DISK}" # Creates iso cause why not
