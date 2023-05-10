//! os kernel module, including some modules: 
//! - (sbi) sbi call : globally sbi call, without sync support / async support. [[TODO]]
//! - (abi) abi call : globally abi call handle. 
//! - (rt) runtime : export the symbol `_start` for program start, init the stack. implicitly some global variables would init here. 
//! - (io) output support: define the terminal output (by sbi interface) format object: writer. 

/// sbi support 
pub const sbi = @import("os/sbi.zig"); 
/// c runtime support 
pub const rt = @import("os/rt.zig"); 
/// output support 
pub const io = @import("os/io.zig"); 
/// log support 
pub const log = @import("os/log.zig");
/// std lib support 
pub const std = @import("std"); 
/// trap support 
pub const trap = @import("os/trap.zig");

/// global panic support 
pub fn panic(error_message: []const u8, stack: ?*std.builtin.StackTrace, len: ?usize) noreturn {
    _ = stack; 
    _ = len; 
    log.err("panic: {s}", .{ error_message, } ); 
    sbi.shutdown(); 
}

pub fn init() void {
    inline for (rt.init) |r | r(); 
}

const root = @import("root"); 

comptime {
    _ = @import("elf.zig"); 
}

pub const trap_handle = 
    trap_value: {
        if (@hasDecl(root, "trap")) 
            break :trap_value root.trap;
        if (@hasDecl(root, "trap_handle")) 
            break :trap_value root.trap_handle; 
        @compileError("no trap handler found");
    }; 
        
pub const virtual_memory_offset : usize = 0; 