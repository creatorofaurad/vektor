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

// commit step 71: 476

// commit step 74: 852

// commit step 75: 504

// commit step 80: 276

// commit step 82: 121

// commit step 83: 367

// commit step 84: 182

// commit step 86: 322

// commit step 87: 228

// commit step 92: 807

// commit step 93: 266

// commit step 96: 723

// commit step 97: 909

// commit step 105: 173

// commit step 107: 402

// commit step 116: 532

// commit step 119: 809

// commit step 120: 873

// commit step 122: 377

// commit step 123: 667

// commit step 127: 295

// commit step 129: 499

// commit step 136: 739

// commit step 139: 179

// commit step 142: 218

// commit step 145: 242

// commit step 146: 363

// commit step 147: 578

// commit step 151: 970

// commit step 153: 714

// commit step 156: 656

// commit step 157: 964

// commit step 158: 784

// commit step 161: 851

// commit step 165: 274

// commit step 169: 197

// commit step 170: 387

// commit step 172: 161

// commit step 173: 930

// commit step 176: 709

// commit step 179: 690

// commit step 183: 288

// commit step 187: 133

// commit step 189: 692

// commit step 208: 967

// commit step 212: 455

// commit step 217: 520

// commit step 218: 676

// commit step 219: 905

// commit step 221: 512

// commit step 222: 839

// commit step 225: 470

// commit step 229: 746

// commit step 230: 481

// commit step 232: 457

// commit step 235: 888

// commit step 236: 921

// commit step 239: 999

// commit step 240: 106

// commit step 243: 968

// commit step 244: 393

// commit step 245: 795

// commit step 246: 880

// commit step 247: 370

// commit step 249: 479

// commit step 250: 147

// commit step 254: 455

// commit step 258: 791

// commit step 259: 766

// commit step 261: 719

// commit step 262: 292
