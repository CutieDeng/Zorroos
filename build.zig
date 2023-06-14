const Build = @import("std").Build;
const builtin = @import("builtin");
const std = @import("std");

const stdout = std.io.getStdOut().writer();

const CrossTarget = std.zig.CrossTarget;

var allo: *std.mem.Allocator = undefined;

pub fn build(b: *Build) !void {
    allo = &b.allocator;

    // var features = std.Target.Cpu.Feature.Set.empty;
    // const single_float: std.Target.riscv.Feature = .d;
    // features.addFeature(@enumToInt(single_float));
    // const a: std.Target.riscv.Feature = .a;
    // features.addFeature(@enumToInt(a));
    // const c: std.Target.riscv.Feature = .c;
    // features.addFeature(@enumToInt(c));

    var select = try CrossTarget.parse(.{
        .arch_os_abi = "riscv64-freestanding-none",
        .diagnostics = null,
    });
    // select.updateCpuFeatures(&features);
    std.log.info("{}", .{select.getCpuFeatures()});
    // select.abi = .none

    try stdout.print("riscv64 os build support. \n", .{});

    if (b.sysroot) |rootdir| {
        try stdout.print("rootdir: {s}\n", .{rootdir});
    }

    const src = b.addExecutable(std.build.ExecutableOptions{
        .name = "out",
        .root_source_file = std.Build.FileSource{ .path = "src/virtual_app.zig" },
        .target = select,
        .optimize = std.builtin.Mode.ReleaseSafe,
    });
    // src.addIncludePath("./src");
    // set the code model as 'medium', to avoid the limitation of the text lookup.
    src.code_model = std.builtin.CodeModel.medium;

    // lto enabled would triggers the error about floating-point abi mismatch.
    // src.want_lto = true;

    // set the link script.
    src.setLinkerScriptPath(.{ .path = "src/linker.ld" });

    // get float abi
    const tar = try std.zig.system.NativeTargetInfo.detect(select);
    const float_abi = tar.target.getFloatAbi();
    std.log.info("float abi: {}", .{float_abi});
    const normal_abi = tar.target.abi;
    std.log.info("normal abi: {}", .{normal_abi});

    b.installArtifact(src);
}
