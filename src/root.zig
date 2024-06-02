const std = @import("std");
const profiler = @import("profiler.zig");

pub const Profiler = profiler.Profiler;
pub const setupGlobalProfiler = profiler.setupGlobalProfiler;
pub const GlobalProfiler = profiler.GlobalProfiler;
pub const OpenBlock = profiler.OpenBlock;
pub const OpenBlockWithProfiler = profiler.OpenBlockWithProfiler;

pub const table = @import("table.zig");
