#!/bin/bash

FILE="bootsector.asm"
ISO="LukOS.iso"

nasm -f bin "${FILE}" -o bootsector.bin # Assembles

dd if=/dev/zero of=disk.img bs=512 count=2880 # Makes blank 1.44MB disk
dd if=bootsector.bin of=disk.img bs=512 count=1 conv=notrunc # Copies bootsector to first 512B of disk

qemu-system-x86_64 -drive format=raw,file=disk.img # Runs

mkisofs -o LukOS.iso -b disk.img ./disk.img # Makes ISO

rm bootsector.bin
rm disk.img
