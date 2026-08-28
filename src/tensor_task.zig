//====================================================================
//                 VEKTOR SIMD TENSOR TASK ENGINE                     
//       Native Matrix Multiplication Workload for Remote Nodes       
//====================================================================
const std = @import("std");
const windows = std.os.windows;

const kernel32 = struct {
    extern "kernel32" fn QueryPerformanceCounter(lpPerformanceCount: *i64) callconv(.c) windows.BOOL;
    extern "kernel32" fn QueryPerformanceFrequency(lpFrequency: *i64) callconv(.c) windows.BOOL;
};

pub const TensorTask = struct {
    pub fn executeMatmul(allocator: std.mem.Allocator, rows: usize, cols: usize) !i64 {
        var start: i64 = 0;
        var end: i64 = 0;
        var freq: i64 = 0;

        _ = kernel32.QueryPerformanceFrequency(&freq);
        _ = kernel32.QueryPerformanceCounter(&start);

        // Allocate Matrices A, B, C
        const a = try allocator.alloc(f32, rows * cols);
        defer allocator.free(a);
        const b = try allocator.alloc(f32, rows * cols);
        defer allocator.free(b);
        const c = try allocator.alloc(f32, rows * cols);
        defer allocator.free(c);

        @memset(a, 1.5);
        @memset(b, 2.0);
        @memset(c, 0.0);

        // Unrolled AVX-512 SIMD Matrix Multiplication Loop (i-k-j layout)
        const Vec = @Vector(16, f32);
        const unroll = 4;
        const vec_step = 16 * unroll;

        var i: usize = 0;
        while (i < rows) : (i += 1) {
            var k: usize = 0;
            while (k < cols) : (k += 1) {
                const a_val = a[i * cols + k];
                const a_vec: Vec = @splat(a_val);

                var j: usize = 0;
                while (j + vec_step <= cols) : (j += vec_step) {
                    comptime var u = 0;
                    inline while (u < unroll) : (u += 1) {
                        const offset = j + u * 16;
                        const b_vec: Vec = b[k * cols + offset ..][0..16].*;
                        var c_vec: Vec = c[i * cols + offset ..][0..16].*;
                        c_vec += a_vec * b_vec;
                        const c_slice: *[16]f32 = c[i * cols + offset ..][0..16];
                        c_slice.* = c_vec;
                    }
                }

                while (j + 15 < cols) : (j += 16) {
                    const offset = j;
                    const b_vec: Vec = b[k * cols + offset ..][0..16].*;
                    var c_vec: Vec = c[i * cols + offset ..][0..16].*;
                    c_vec += a_vec * b_vec;
                    const c_slice: *[16]f32 = c[i * cols + offset ..][0..16];
                    c_slice.* = c_vec;
                }

                while (j < cols) : (j += 1) {
                    c[i * cols + j] += a_val * b[k * cols + j];
                }
            }
        }

        _ = kernel32.QueryPerformanceCounter(&end);

        if (freq == 0) return 0;
        const elapsed_ms = @divTrunc((end - start) * 1000, freq);
        return elapsed_ms;
    }
};
