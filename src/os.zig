//! 操作系统内核核心组件，所有其他模块的父模块。
//!
//! 该模块包含了以下各模块：
//!
//! - (sbi) sbi 调用：全局的 sbi 调用，不包含同步支持 / 异步支持。[[TODO]]
//! - (rt) 基础程序运行时：导出 `_start` 符号，初始化栈，并进行 bss 的零初始化。[[TODO: 多核初始化支持]]
//! - (io) 输出支持：定义了最基础的终端输出对象 io.stdout, 通过 sbi 接口输出。
//! - (trap) 中断支持：定义了基础的中断处理函数，以及中断处理函数的注册接口[[TODO]]。

/// sbi 模块
pub const sbi = @import("os/sbi.zig");
/// c runtime 模块
pub const rt = @import("os/rt.zig");
/// io 模块
pub const io = @import("os/io.zig");
/// zig 标准库
pub const std = @import("std");
/// trap 模块
pub const trap = @import("os/trap.zig");
/// log 模块
pub const log = std.log;
/// memory 模块
pub const memory = @import("os/memory.zig");

/// 虚拟地址入口
pub fn vmain() align(4) void {
    asm volatile ("sfence.vma");
    rt.setTrap(0);
    @call(.always_inline, root.vmain, .{});
}

/// 全局 panic 函数
pub fn panic(error_message: []const u8, stack: ?*std.builtin.StackTrace, len: ?usize) noreturn {
    _ = stack;
    _ = len;
    std.log.err("panic: {s}", .{
        error_message,
    });
    sbi.shutdown();
}

pub fn init() void {
    rt.emptyBss();
    memory.init();
}

const root = @import("root");

comptime {
    _ = @import("elf.zig");
}

/// 异常、中断处理函数
pub const trap_handle =
    root.trap_handle;

pub const virtual_memory_offset: usize = 0;

pub const std_options = struct {
    pub fn logFn(
        comptime message_level: std.log.Level,
        comptime scope: @Type(.EnumLiteral),
        comptime format: []const u8,
        args: anytype,
    ) void {
        const level_txt = comptime message_level.asText();
        const prefix2 = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";
        const stderr = io.stdout.writer();
        // origin codes in std;
        // const stderr = std.io.getStdErr().writer();
        // std.debug.getStderrMutex().lock();
        // defer std.debug.getStderrMutex().unlock();
        nosuspend stderr.print(level_txt ++ prefix2 ++ format ++ "\n", args) catch return;
    }
};
