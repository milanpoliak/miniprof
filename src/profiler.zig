const std = @import("std");
const Timer = std.time.Timer;
const BlockList = std.ArrayList(*Block);
const Allocator = std.mem.Allocator;

pub const Profiler = struct {
    blocks: BlockList = undefined,
    timer: Timer = undefined,
    current: ?*Block = null,

    pub fn init(allocator: Allocator, capacity: usize) !Profiler {
        return Profiler{
            .blocks = try BlockList.initCapacity(allocator, capacity),
            .timer = try Timer.start(),
        };
    }

    pub fn addBlock(self: *Profiler, block: *Block) !void {
        block.profiler = self;
        try self.blocks.append(block);
    }

    pub fn deinit(self: *Profiler) void {
        self.blocks.deinit();
    }
};

pub const GlobalProfiler = @constCast(&Profiler{});
pub fn setupGlobalProfiler(allocator: Allocator, capacity: usize) !void {
    GlobalProfiler.blocks = try BlockList.initCapacity(allocator, capacity);
    GlobalProfiler.timer = try Timer.start();
}

const Block = struct {
    profiler: ?*Profiler = null,

    label: []const u8,
    total_time: u64 = 0,
    exclusive_time: u64 = 0,
    hits: u64 = 0,

    start_time: u64 = 0,
    parent: ?*Block = null,

    pub fn open(self: *Block) void {
        self.parent = self.profiler.?.current;
        self.profiler.?.current = self;
        self.start_time = self.profiler.?.timer.read();
        self.hits += 1;
    }

    pub fn close(self: *Block) void {
        const now = self.profiler.?.timer.read();
        const elapsed = now - self.start_time;

        self.exclusive_time +%= elapsed;
        self.total_time += elapsed;

        if (self.parent) |parent| {
            parent.exclusive_time -%= elapsed;
        }

        self.profiler.?.current = self.parent;
        self.parent = null;
    }
};

fn MakeBlock(comptime block: Block) *Block {
    return @constCast(&block);
}

pub inline fn OpenBlock(comptime label: []const u8) *Block {
    var block = comptime MakeBlock(Block{
        .label = label,
    });

    if (block.profiler == null) {
        GlobalProfiler.addBlock(block) catch unreachable;
    }

    block.open();

    return block;
}

pub inline fn OpenBlockWithProfiler(comptime label: []const u8, profiler: *Profiler) *Block {
    var block = comptime MakeBlock(Block{
        .label = label,
    });

    if (block.profiler == null) {
        profiler.addBlock(block) catch unreachable;
    }

    block.open();

    return block;
}
