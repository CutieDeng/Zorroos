/// The special symbol, describe all applications (would be run) info. 
extern const app_numbers: usize ; 

/// The application info pointer ~ 
const app_info = @ptrCast([*]usize, &app_numbers); 

pub const os = @import("os.zig"); 
const log = os.log; 
const std = os.std; 

pub const traplib = os.trap; 

pub const code = @import("trap/code.zig"); 

export fn main() callconv(.C) void {

    os.init(); 

    log.debug("init os", .{});

    {
        var len = app_info[0]; 
        var offsetptr = @ptrCast([*] [2] usize, app_info + 1); 
        manager = .{
            .app_numbers = len, 
            .app = offsetptr[0..len], 
        }; 
    }

    var uninit_trapcontext : traplib.TrapContext = undefined; 

    manager.run_next_or_exit( &uninit_trapcontext ); 

}

/// 4K stack, align is the same... it would at the start of the page actually. 
pub var user_stack : [4096] u8 align(4096) = undefined; 

pub var manager : Manager = undefined; 

pub const Manager = struct {
    app_numbers: usize, 
    current : usize = 0, 
    app: [] [2] usize, 

    fn run_next_or_exit(self: *Manager, sp: * traplib.TrapContext ) noreturn {
        if (self.current == self.app_numbers) {
            log.info("finish all applications, shutdown now!", .{});
            os.sbi.shutdown(); 
        }
        var context = sp; 
        log.info("number: {}", .{ self.app_numbers }); 
        // log.info("current: {}", .{ self.current }); 
        context.* = traplib.TrapContext {
            .x = blk: {
                var x: @TypeOf(context.x) = undefined; 
                x[2] = @ptrToInt(&user_stack) + @sizeOf(@TypeOf(user_stack)); 
                break :blk x; 
            }, 
            .sepc = 0x80400000, 
            .sstatus = blk: {
                var x: usize = asm ("csrr %[x], sstatus": [x] "=r" (-> usize));
                x &= ~@as(usize, 0x100);
                break :blk x; 
            }
        }; 
        {
            var len = self.app[self.current][1] - self.app[self.current][0]; 
            @memcpy(@intToPtr([*] u8, 0x80400000), @intToPtr([*] const u8, self.app[self.current][0]), len); 
            asm volatile ("fence.i" ::: "~memory"); 
        }
        self.current += 1; 
        traplib.restore(context); 
        // @panic("not implemented yet"); 
    }

}; 


comptime {
    _ = traplib; 
}

/// define the panic function, as the os kernel function . 
pub const panic = os.panic; 

pub fn trap(trap_context: *traplib.TrapContext) callconv(.C) *traplib.TrapContext {
    const scause: usize = asm (
        \\csrr %[r1], scause
        : [r1] "=r" (-> usize) 
    ); 
    const stval : usize = asm (
        \\csrr %[r2], stval
        : [r2] "=r" (-> usize) 
    ); 
    log.debug("trap handle {{ cause: {}, value: 0x{x}. }}", .{ scause, stval, }); 
    if (scause & 0x8000_0000 == 0) {
        const scause_val = scause; 
        const exception_val = @intToEnum(code.Exception, scause_val);
        log.info("exception: {}", .{ exception_val, }); 
        if (exception_val == code.Exception.environment_call_from_u) {
            @panic(")"); 
        } else {
            @panic("not implemented yet");
        }
    }

    // special case ~ ebreak call 
    if (scause == 3) {
        trap_context.sepc += 2; 
        return trap_context; 
    } else {
        manager.run_next_or_exit( trap_context ); 
    }

}

comptime {
    _ = @import("app/apps.zig"); 
}