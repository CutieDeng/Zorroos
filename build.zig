const Build = @import("std").Build; 
const builtin = @import("builtin");
const std = @import("std");

const stdout = std.io.getStdOut().writer();

const CrossTarget = std.zig.CrossTarget;

var allo : * std.mem.Allocator = undefined; 

pub fn build(b: *Build) !void {

    const echo_step : * Build.Step = b.step( "echo", "..." ); 

    allo = & b.allocator; 

    echo_step.makeFn = struct {
        fn make(step: *Build.Step) !void {
            _ = step; 
            try stdout.print("echo step. \n", .{}); 
            var sp = std.ChildProcess.init( &[_] [] const u8 {
                "ls", 
            }, allo.* ); 
            const term = try sp.spawnAndWait(); 
            try stdout.print( "exit with code: {}.\n", .{ term.Exited }); 
        }
    }.make; 

    const select = try CrossTarget.parse(.{
        .arch_os_abi = "riscv64-freestanding-none", 
        .diagnostics = null, 
    }); 

    try stdout.print("riscv64 os build support. \n", .{} ); 

    if (b.sysroot) |rootdir| {
        try stdout.print("rootdir: {s}\n", .{rootdir});
    } 

    const src = b.addExecutable( std.build.ExecutableOptions {
        .name = "out", 
        .root_source_file = std.Build.FileSource { .path = "src/app.zig" }, 
        .target = select, 
        .optimize = std.builtin.Mode.ReleaseSafe, 
    }); 
    src.addIncludePath("./src"); 
    // set the code model as 'medium', to avoid the limitation of the text lookup. 
    src.code_model = std.builtin.CodeModel.medium;
    // disable LTO, to keep the 'unused' data. 
    src.want_lto = true; 
    // set the link script. 
    src.setLinkerScriptPath(.{ .path = "src/linker.ld" });

    src.install(); 
}

