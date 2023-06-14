#!/bin/sh 

QEMU=qemu-system-riscv64

$QEMU \
    -machine virt \
    -nographic \
    -bios default \
    -kernel ./zig-out/bin/out \
    $*
