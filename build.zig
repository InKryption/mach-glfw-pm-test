const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(std.Build.ExecutableOptions{
        .name = "playground",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.install();

    const mach_glfw_dep = b.dependency("mach-glfw", .{
        .optimize = optimize,
        .target = target,
    });
    exe.addModule("mach-glfw", mach_glfw_dep.module("mach-glfw"));
    const libglfw = mach_glfw_dep.artifact("glfw-static");
    exe.linkLibrary(libglfw);
    exe.installLibraryHeaders(libglfw);

    const run_cmd_step: *std.build.Step = blk: {
        if (target.os_tag != null or target.cpu_arch != null) {
            const run_cmd = exe.runEmulatable();
            break :blk &run_cmd.step;
        } else {
            const run_cmd = exe.run();
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }
            break :blk &run_cmd.step;
        }
    };
    run_cmd_step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(run_cmd_step);

    const exe_tests = b.addTest(std.Build.TestOptions{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
