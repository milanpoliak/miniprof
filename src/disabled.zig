const std = @import("std");
const Timer = std.time.Timer;
const BlockList = std.ArrayList(*Block);
const Allocator = std.mem.Allocator;

pub const Profiler = struct {
    blocks: BlockList = undefined,

    pub fn init(_: Allocator, _: usize) !Profiler {
        return Profiler{};
    }

    pub fn addBlock(_: *Profiler, _: *Block) !void {}

    pub fn deinit(_: *Profiler) void {}
};

pub const GlobalProfiler = @constCast(&Profiler{});
pub fn setupGlobalProfiler(_: Allocator, _: usize) !void {}

const Block = struct {
    pub fn open(_: *Block) void {}

    pub fn close(_: *Block) void {}
};

fn MakeBlock(comptime block: Block) *Block {
    return @constCast(&block);
}

pub inline fn OpenBlock(comptime _: []const u8) *Block {
    return comptime MakeBlock(Block{});
}

pub inline fn OpenBlockWithProfiler(comptime _: []const u8, _: *Profiler) *Block {
    return comptime MakeBlock(Block{});
}

pub const table = struct {
    pub fn writeTable(_: *const Profiler, _: anytype, _: std.mem.Allocator) !void {}
};
