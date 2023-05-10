//! The zig runtime of the os. 
//! In this module, the start entry `_start` is defined, and it would jump to the function `main`, which defined in root project ~ 
//! Also, the stack part is defined here, with the size 4KiB. 
//! Some symbols defined in linker script are used here to give a better initialize support. 

comptime {
    asm (
        \\.section .text.my_entry 
        \\.globl _start 
        \\_start: 
        \\  la sp, boot_stack_top
        \\  call main 
        \\.section .bss.stack 
        \\boot_stack:
        \\.space 4096
        \\.globl boot_stack_top
        \\boot_stack_top: 
    ); 
}

/// This is the symbol 'sbss' defined in linker.ld, start of the segment '.bss'. 
extern const sbss : u8 align(4096) ; 

/// Defined in linker.ld, end of the segment '.bss'. 
extern const ebss : u8 align (4096) ; 

/// Make the content of segment '.bss' all zero; zero initialized. 
fn emptyBss() callconv(.Inline) void {
    const start_ptr : [*]u8 = @ptrCast([*]u8, &sbss); 
    const length = @ptrToInt(&ebss) - @ptrToInt(&sbss); 
    @memset(start_ptr, 0, length);
}

/// init fn array: define the init functions orderly, call them to initialize the runtime. 
/// - emptyBss: this fn flush the segment '.bss' . 
pub const init = [_] *const fn () callconv(.Inline) void { emptyBss, setTrap, os.trap.init_virtual_memory }; 

const os = @import("root") .os; 

fn setTrap() callconv(.Inline) void {
    // the addr [XLEN - 1: 2] handle addr ; 
    // mode = 0 : pc to base 
    // assume the base is 4 byte aligned.
    // const base = @ptrToInt(&os.trap.trap); 
    const base = @ptrToInt(&os.trap.trap); 

    if (base & 0x3 != 0) {
        @panic("trap base not 4 byte aligned!"); 
    }

    // set the trap handle
    asm volatile (
        \\csrw stvec, %[val]
        : : [val] "r" (base) 
    ); 
} 