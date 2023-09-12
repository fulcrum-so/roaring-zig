const std = @import("std");
const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/test.zig" },
    });
    add(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    var example = b.addExecutable(.{
        .name = "example",
        .root_source_file = .{ .path = "src/example.zig" },
        .target = target,
        .optimize = optimize,
    });
    add(example);

    const run_example = b.addRunArtifact(example);
    run_example.step.dependOn(&example.step); // gotta build it first
    b.step("run-example", "Run the example").dependOn(&run_example.step);
}

/// Add Roaring Bitmaps to your build process
pub fn add(lib: *std.Build.Step.Compile) void {
    lib.addAnonymousModule("roaring", .{ .source_file = .{ .path = "src/roaring.zig" } });
    lib.linkLibC();
    lib.addCSourceFile(.{ .file = .{ .path = "croaring/roaring.c" }, .flags = &.{ "-fPIC", "-std=c11", "-O3", "-Wall", "-Wextra", "-pedantic", "-Wshadow" } });
    lib.addIncludePath(.{ .path = "croaring" });
}
