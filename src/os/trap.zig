pub const TrapContext = extern struct {
    x: [32]usize,
    sstatus: usize,
    sepc: usize,
};

const os = @import("root").os;
const std = os.std; 

comptime {
    // 向全局导出异常处理符号 trap_handle 
    @export(os.trap_handle, std.builtin.ExportOptions{
        .name = "trap_handle",
        .section = ".text",
    });
}

// trap 符号：用于预处理当前的栈结构；
// restore 符号：用于恢复当前的栈结构；
// trap_handle 符号：实际处理中断的代码

comptime {
    asm (
        \\.altmacro 
        \\.macro saverg n
        \\  sd x\n, 8*\n(sp)
        \\.endm 
        \\.align 2 
        \\.section .text
        \\trap: 
        \\csrrw sp, sscratch, sp
        \\addi sp, sp, -34 * 8
        \\sd x1, 8(sp)
        \\sd x3, 3*8(sp)
        \\.set n, 5
        \\.rept 27 
        \\  saverg %n 
        \\  .set n, n+1
        \\.endr 
        \\csrr t0, sstatus
        \\csrr t1, sepc
        \\sd t0, 32*8(sp)
        \\sd t1, 33*8(sp)
        \\csrr t2, sscratch
        \\sd t2, 2*8(sp)
        \\mv a0, sp
        \\call trap_handle
        \\.macro loadrg n
        \\  ld x\n, \n*8(sp)
        \\.endm 
        \\.align 2
        \\restore: 
        \\  mv sp, a0
        \\  ld t0, 32*8(sp)
        \\  ld t1, 33*8(sp)
        \\  ld t2, 2*8(sp)
        \\  csrw sstatus, t0 
        \\  csrw sepc, t1
        \\  csrw sscratch, t2
        \\  loadrg 1
        \\  loadrg 3
        \\.set n, 5
        \\.rept 27
        \\  loadrg %n
        \\  .set n, n+1
        \\.endr
        \\addi sp, sp, 34*8
        \\csrrw sp, sscratch, sp
        \\sret 
    );
}

pub extern fn restore(kernel_stack_pointer: *TrapContext) align(4) callconv(.C) noreturn;

pub extern fn trap() align(4) callconv(.C) void;

pub const kernel_memory_page : [4096] u8 align(4096) = [_] u8 { 0 } ** 4096; 

pub const log = os.log; 

pub fn init_virtual_memory() callconv(.Inline) void {
    // const then_actual_ptr = @ptrToInt(then); 
    if (os.virtual_memory_offset % 4 != 0) { 
        @compileError("virtual memory offset must be a multiple of 4"); 
    } 
    const then_virtual_ptr = 4 +% os.virtual_memory_offset; 
    const then_virtual_fn = @intToPtr(*align(4) const fn () void, then_virtual_ptr); 
    log.info("kernel memory page: {*}", .{&kernel_memory_page});
    log.info("then_virtual_fn = {x}", .{then_virtual_fn});  
    if (true) {
        return ; 
    }
    // write this ptr to the trap vector ~ 
    asm volatile (
        \\csrw stvec, %0
        : : [ptr] "r" (then_virtual_fn) 
    ); 
    // attempt to build the virtual page at the physical page x 
    var x: usize = undefined; 
    var ptr = @shlExact(x, 12); 
    asm volatile (
        \\csrw satp, %0
        : : [ptr] "r" (ptr) 
    ); 
    // set the mmu 
    asm volatile (
        \\csrw mstatus, %0
        : : [ptr] "r" (0x1800) 
    ); 
}

