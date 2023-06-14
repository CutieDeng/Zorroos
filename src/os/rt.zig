//! The zig runtime of the os.
//! In this module, the start entry `_start` is defined, and it would jump to the function `main`, which defined in root project ~
//! Also, the stack part is defined here, with the size 4KiB.
//! Some symbols defined in linker script are used here to give a better initialize support.
//!

const os = @import("root").os;
const std = @import("std");

comptime {
    asm (
        \\.section .text.my_entry 
        \\.globl _start 
        \\_start: 
        \\  la sp, boot_stack_top
        \\  call main 
        \\.section .bss.stack 
        \\.align 12 
        \\boot_stack:
        \\.space 4096
        \\.globl boot_stack_top
        \\boot_stack_top: 
    );
}

/// This is the symbol 'sbss' defined in linker.ld, start of the segment '.bss'.
extern const sbss: u8 align(4096);

/// Defined in linker.ld, end of the segment '.bss'.
extern const ebss: u8 align(4096);

/// Make the content of segment '.bss' all zero; zero initialized.
pub inline fn emptyBss() void {
    const start_ptr: [*]u8 = @ptrCast([*]u8, &sbss);
    const length = @ptrToInt(&ebss) - @ptrToInt(&sbss);
    const to_set_slice = start_ptr[0..length];
    @memset(to_set_slice, 0);
}

pub inline fn setTrap(trapFn: u64) void {
    // the addr [XLEN - 1: 2] handle addr ;
    // mode = 0 : pc to base
    // assume the base is 4 byte aligned.
    // const base = @ptrToInt(&os.trap.trap);
    const base = if (trapFn == 0) @ptrToInt(&os.trap.trap) else trapFn;

    if (!std.mem.isAligned(base, 4)) {
        std.debug.panic("{s}", .{"trap handle addr is not aligned"});
    }

    // set the trap handle
    asm volatile (
        \\csrw stvec, %[0]
        :
        : [@"0"] "r" (base),
    );
}
