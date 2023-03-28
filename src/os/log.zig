//! Log module. 
//! In this module, you can use log in different level and make them 
pub const LogLevel = enum { Debug, Info, Warn, Error, }; 

const os = @import("root").os; 
/// io module is used to print log.
const io = os.io; 

/// The default log level is Debug. 
/// You can change it to other level to filter log. 
pub const log_level = LogLevel.Debug; 

pub fn log(comptime level : LogLevel , comptime fmt: [] const u8, a : anytype ) callconv(.Inline) void {
    if (@enumToInt(level) < @enumToInt(log_level)) return; 
    const print = io.print; 
    switch (level) {
        LogLevel.Debug => print("\x1b[1;36m[ DEBUG] " ++ fmt ++ "\x1b[0m\n", a), 
        LogLevel.Info => print("\x1b[1;37m[  INFO] " ++ fmt ++ "\x1b[0m\n", a), 
        LogLevel.Warn => print("\x1b[1;33m[  WARN] " ++ fmt ++ "\x1b[0m\n", a),
        LogLevel.Error => print("\x1b[1;31m[SEVERE] " ++ fmt ++ "\x1b[0m\n", a), 
    }
}

pub fn debug(comptime fmt: [] const u8, a : anytype ) callconv(.Inline) void {
    log(LogLevel.Debug, fmt, a); 
}

pub fn info(comptime fmt: [] const u8, a : anytype ) callconv(.Inline) void {
    log(LogLevel.Info, fmt, a); 
}

pub fn warn(comptime fmt: [] const u8, a : anytype ) callconv(.Inline) void {
    log(LogLevel.Warn, fmt, a); 
}

pub fn err(comptime fmt: [] const u8, a : anytype ) callconv(.Inline) void {
    log(LogLevel.Error, fmt, a); 
}