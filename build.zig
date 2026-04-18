const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "vektor_kernel",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/vektor_kernel.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run Vektor Mesh Kernel");
    run_step.dependOn(&run_cmd.step);
}

// commit step 3: 214

// commit step 6: 701

// commit step 10: 742

// commit step 12: 360

// commit step 14: 697

// commit step 15: 845

// commit step 22: 101

// commit step 25: 126

// commit step 32: 974

// commit step 37: 182

// commit step 40: 191

// commit step 42: 839

// commit step 46: 177

// commit step 48: 418

// commit step 49: 246

// commit step 53: 801

// commit step 54: 375

// commit step 55: 925

// commit step 64: 763

// commit step 66: 101

// commit step 69: 963

// commit step 70: 797
