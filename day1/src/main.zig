const std = @import("std");
const expect = std.testing.expect;
const ArrayList = std.ArrayList;

pub fn calculate(filename: []const u8, second_stage: bool) !u128 {
    var sum: u128 = 0;
    const input = try std.fs.cwd().openFile(
        filename,
        .{ .mode = .read_only, .lock = .none },
    );
    defer input.close();

    var buffer: [14000]u8 = undefined;
    @memset(&buffer, 0);
    _ = try input.readAll(&buffer);

    var alloc_buffer: [140000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&alloc_buffer);
    const allocator = fba.allocator();

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var it = std.mem.splitScalar(u8, &buffer, '\n');
    while (it.next()) |line| {
        try lines.append(line);
    }
    // Remove empty last line
    _ = lines.pop();
    std.debug.print("Last element: {s}\n", .{lines.getLast()});

    var array_1: [1000]i128 = undefined;
    @memset(&array_1, 0);
    var array_2: [1000]i128 = undefined;
    @memset(&array_2, 0);

    for (lines.items, 0..) |line, i| {
        std.debug.print("{s}\n", .{line});
        var it2 = std.mem.splitSequence(u8, @constCast(line), "   ");
        var j: u32 = 0;
        while (it2.next()) |x| {
            std.debug.print("{s}\n", .{x});
            if (j % 2 == 0) {
                std.debug.print("Add to array_1\n", .{});
                array_1[i] = try std.fmt.parseInt(i128, x, 10);
            } else {
                std.debug.print("Add to array_2\n", .{});
                array_2[i] = try std.fmt.parseInt(i128, x, 10);
            }
            j += 1;
        }
    }
    std.mem.sort(i128, &array_1, {}, std.sort.asc(i128));
    std.mem.sort(i128, &array_2, {}, std.sort.asc(i128));
    if (!second_stage) {
        for (array_1, 0..) |_, i| {
            sum += @abs(array_2[i] - array_1[i]);
        }
    } else {
        for (array_1) |x| {
            var count: i128 = 0;
            for (array_2) |y| {
                if (x == y) {
                    count += 1;
                }
            }
            sum += @abs(count * x);
        }
    }
    return sum;
}

pub fn main() !void {
    var result: u128 = 0;
    const filename = "input";
    result = try calculate(filename, false);

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Result for 1: {d}\n", .{result});

    result = try calculate(filename, true);

    try stdout.print("Result for 2: {d}\n", .{result});

    try bw.flush();
}

test "initial test" {
    var result: u128 = 0;

    const filename = "sampleinput";
    result = try calculate(filename, false);

    std.debug.print("Result: {d}\n", .{result});
    try expect(result == 11);
}

test "second stage test" {
    var result: u128 = 0;

    const filename = "sampleinput";
    result = try calculate(filename, true);

    std.debug.print("Result: {d}\n", .{result});
    try expect(result == 31);
}
