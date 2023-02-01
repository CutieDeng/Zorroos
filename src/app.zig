/// The special symbol, describe all applications (would be run) info. 
extern const app_numbers: usize ; 

/// The application info pointer ~ 
const app_info = @ptrCast([*]usize, &app_numbers); 

pub const os = @import("os.zig"); 

pub const writer = os.writer; 

extern fn trap() align(4) callconv(.C) void; 

export fn main() callconv(.C) void {
    os.init() catch |a| { @panic(@errorName(a)); }; 

    // the addr [XLEN - 1: 2] handle addr ; 
    // mode = 0 : pc to base 
    const base = @ptrToInt(&trap);
    // const stvec_val : usize = base & ~@as(usize, 0x3); 
    const stvec_val : usize = base; 

    writer.print("stvec: 0x{x}!\n", .{ stvec_val }) catch unreachable; 

    // set the trap handle
    asm volatile (
        \\csrw stvec, %[val]
        : : [val] "r" (stvec_val) 
    ); 

    {
        const sstatus : usize = 0b1_0011_0000; 
        asm volatile ("csrw sstatus, %[s]" : : [s] "r" (sstatus) ); 
    }

    {
        var len = app_info[0]; 
        var offsetptr = @ptrCast([*] [2] usize, app_info + 1); 
        manager = .{
            .app_numbers = len, 
            .app = offsetptr[0..len], 
        }; 
        // check the manager val ~ 
        writer.print("\x1b[36;1m[  INFO] Initial the manager: \n\tnumber: {}\n\tcurrent: {}\n\tapp: {{ ", 
            .{ manager.app_numbers, manager.current, }) catch unreachable; 
        for (manager.app) |a| {
            writer.print("start: 0x{x}, end: 0x{x}; ", .{ a[0], a[1] }) catch unreachable; 
        }
        writer.writeAll("}\x1b[0m\n") catch unreachable; 
    }

    manager.run_next_or_exit(); 

}

pub var manager : Manager = undefined; 

pub const Manager = struct {
    app_numbers: usize, 
    current : usize = 0, 
    app: [] [2] usize, 

    pub fn run_next_or_exit(self: *Manager) noreturn {
        if (self.current == self.app_numbers) {
            // shutdown the computer, when all applications are run done. 
            writer.print("\x1b[32;1m[SYSTEM] All applications are run done. \x1b[0m\n", .{} ) catch unreachable; 
            os.sbi.shutdown(); 
        }
        writer.print("\x1b[36;1m[  INFO] Prepare to run the next application {{ index = {} }} \x1b[0m\n", .{ self.current }) catch unreachable; 
        // when run here, it must be the kernel stack used. 
        // display the kernel stack pointer info: 
        writer.print("\x1b[34;1m[ DEBUG] At Manager.run_next_or_exit debug, now sp: 0x{x}.\x1b[0m\n", .{ 
            asm ( "" : [_] "={sp}" (-> usize) ), 
        }) catch unreachable; 
        var context :traplib.TrapContext = undefined; 
        context = traplib.TrapContext {
            .x = blk: {
                var x: @TypeOf(context.x) = undefined; 
                x[2] = @ptrToInt(&os.user_stack); 
                break :blk x; 
            }, 
            .sepc = 0x80400000, 
            .sstatus = blk: {
                var x: usize = asm ("csrr %[x], sstatus": [x] "=r" (-> usize));
                writer.print("{b:032}\n", .{x}) catch unreachable; 
                x &= ~@as(usize, 0x100);
                writer.print("{b:032}\n", .{x}) catch unreachable; 
                break :blk x; 
            }
        }; 
        {
            @memset(@intToPtr([*] u8, 0x80400000), 0, 0x100000); 
            var len = self.app[self.current][1] - self.app[self.current][0]; 
            @memcpy(@intToPtr([*] u8, 0x80400000), @intToPtr([*] const u8, self.app[self.current][0]), len); 
            asm volatile ("fence.i"); 
        }
        self.current += 1; 
        traplib.restore(&context); 
    }

}; 

pub const traplib = @import("trap.zig"); 

comptime {
    _ = traplib; 
}
