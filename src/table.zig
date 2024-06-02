const Profiler = @import("profiler.zig").Profiler;
const std = @import("std");
const Writer = std.fs.File.Writer;

const Row = [5][]const u8;

pub fn writeTable(profiler: *const Profiler, writer: anytype, allocator: std.mem.Allocator) !void {
    const header: Row = .{ "Block", "Exclusive time", "% of total time", "Total time", "Hits" };
    var rows = try std.ArrayList(Row).initCapacity(allocator, profiler.blocks.items.len);
    defer rows.deinit();

    var col_lengths: [5]usize = undefined;

    for (header, 0..) |h, i| {
        col_lengths[i] = h.len + 2;
    }

    var total_time: u64 = 0;

    for (profiler.blocks.items) |block| {
        total_time += block.exclusive_time;
    }

    for (profiler.blocks.items) |block| {
        const row = Row{
            try std.fmt.allocPrint(allocator, "{s}", .{block.label}),
            try std.fmt.allocPrint(allocator, "{}", .{block.exclusive_time}),
            try std.fmt.allocPrint(allocator, "{d:.2}", .{@as(f64, @floatFromInt(block.exclusive_time)) / @as(f64, @floatFromInt(total_time)) * 100}),
            try std.fmt.allocPrint(allocator, "{}", .{block.total_time}),
            try std.fmt.allocPrint(allocator, "{}", .{block.hits}),
        };

        for (row, 0..) |r, i| {
            col_lengths[i] = @max(col_lengths[i], r.len + 2);
        }

        try rows.append(row);
    }

    for (header, col_lengths) |h, l| {
        try writeCell(writer, h, l);
    }

    try writer.writeAll("\n");

    for (col_lengths) |l| {
        try writer.writeByteNTimes('-', l);
    }

    try writer.writeAll("\n");

    for (rows.items) |r| {
        for (r, col_lengths) |c, l| {
            try writeCell(writer, c, l);
            allocator.free(c);
        }

        try writer.writeAll("\n");
    }
}

fn writeCell(writer: Writer, text: []const u8, len: usize) !void {
    const padding = len - text.len;

    try writer.writeAll(text);
    try writer.writeByteNTimes(' ', padding);
}
