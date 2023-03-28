//! This part is the IO part. 
//! The class `Stdout` is the core object defined to give the output abstract. 
//! The `stdout` is the globally unique instance of `Stdout`: only use it to print the info ~ 
//! 
//! ## Module Structure 
//! ### sbi module 
//! io module should use the sbi interface to output the info, on the console. 
//! 

const os = @import("root") .os; 
/// The sbi interface module. 
/// The sbi interface is the core interface to interact with the OS. (actually by sbi to manipulate the machine) 
const sbi = os.sbi; 

/// ### The stdout instance. 
/// The stdout is the globally unique instance of `Stdout`.
/// Only use it to print the info ~ 
pub const stdout = Stdout { } ; 

/// The stdout writer. 
/// The writer is the core object to output the info. 
/// I have known that you would get the error info when you use the writer. 
/// So just use `print` method ~ in the same module to avoid it! 
pub const writer = stdout.writer(); 

/// The print method. 
/// The print method is the core method to output the info.
/// It will use the `writer` to output the info.
/// The `print` method will not return the error info.
pub fn print (comptime a: [] const u8, b: anytype ) callconv(.Inline) void {
    // handle the error by shutdown my machine. 
    writer.print(a, b) catch sbi.shutdown(); 
}

/// The std support. 
const std = @import("std"); 

/// The output operator is dependent by the sbi interface. 
const sys = @import("sbi.zig");

/// The output abstract, no member variables till now. 
const Stdout = struct {

    fn write(_: Stdout, data: []const u8) EmptyError!usize {
        // do not promote the efficiency of the program. 
        // @call(.{ .modifier = .always_inline, }, sys.unsafePrintBuffer, .{ data }); 
        for (data) | d| {
            sbi.consolePutchar(d);
        }
        return data.len; 
    }

    pub fn writer(self: Stdout) Writer {
        return .{
            .context = self, 
        }; 
    }

    pub fn lock(self: *Stdout) void {
        // do nothing. 
        _ = self; 
    }

    pub fn unlock(self: *Stdout) void {
        // do nothing. 
        _ = self;
    }

}; 

/// Empty set of error. Because we won't meet error when we output by `sbi`. 
const EmptyError = error {};

const Writer = std.io.Writer(
    Stdout, 
    EmptyError, 
    Stdout.write
); 
