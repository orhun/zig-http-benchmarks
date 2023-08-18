const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Standalone-Server uses asio (standalone/non-boost)
    const libasio_dep = b.dependency("standaloneServer", .{
        .target = target,
        .optimize = optimize,
    });
    const libasio = libasio_dep.artifact("Standalone-server");

    const exe = b.addExecutable(.{
        .name = "cpp-asio-httpserver",
        .target = target,
        .optimize = optimize,
    });
    // get include to zig-cache/i/{hash-pkg}/include
    for (libasio.include_dirs.items) |include| {
        exe.include_dirs.append(include) catch {};
    }
    exe.addCSourceFile(.{
        .file = .{
            .path = "src/main.cpp",
        },
        .flags = &.{
            "-Wall",
            "-Wextra",
            "-Wshadow",
        },
    });
    // use standalone asio - non-boost
    exe.defineCMacro("ASIO_STANDALONE", null);
    exe.linkLibrary(libasio);
    exe.linkLibCpp();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", b.fmt("Run the {s} app", .{exe.name}));
    run_step.dependOn(&run_cmd.step);
}
