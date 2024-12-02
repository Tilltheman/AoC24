const std = @import("std");
const expect = std.testing.expect;

pub fn is_safe(line: []const u8) !bool {
    var buffer: [10]i32 = undefined;
    @memset(&buffer, 0);

    var it = std.mem.splitScalar(u8, line, ' ');
    var i: u32 = 0;
    while (it.next()) |item| {
        buffer[i] = try std.fmt.parseInt(i32, item, 10);
        i += 1;
    }

    var j: u32 = 0;
    if (buffer[0] == buffer[1]) return false;
    var sign: i8 = 0;
    if (buffer[0] > buffer[1]) {
        sign = -1;
    } else {
        sign = 1;
    }

    while (buffer[j] > 0 and j < buffer.len - 1) : (j += 1) {
        const x: i32 = buffer[j];
        const y: i32 = buffer[j + 1];
        if (y == 0) break;
        if (@abs(x - y) > 3) {
            std.debug.print("Bigger3 {d} {d}\n", .{ x, y });
            return false;
        }

        if (@abs(x - y) == 0) {
            std.debug.print("NoSlope {d} {d}\n", .{ x, y });
            return false;
        }

        var cur_sign: i8 = 0;
        if (x > y) {
            cur_sign = -1;
        } else {
            cur_sign = 1;
        }
        if (cur_sign != sign) {
            std.debug.print("SignChanged {d} {d}\n", .{ x, y });
            return false;
        }
    }
    return true;
}

pub fn is_safe3(buffer: anytype) !bool {
    if (buffer.items[0] == buffer.items[1]) return false;
    var sign: i8 = 0;
    if (buffer.items[0] > buffer.items[1]) {
        sign = -1;
    } else {
        sign = 1;
    }
    for (buffer.items[0 .. buffer.items.len - 1], 0..) |_, j| {
        const x: i32 = buffer.items[j];
        const y: i32 = buffer.items[j + 1];
        if (y == 0) break;
        if (@abs(x - y) > 3) {
            return false;
        }

        if (@abs(x - y) == 0) {
            return false;
        }

        var cur_sign: i8 = 0;
        if (x > y) {
            cur_sign = -1;
        } else {
            cur_sign = 1;
        }
        if (cur_sign != sign) {
            return false;
        }
    }
    return true;
}

pub fn is_safe2(line: []const u8) !bool {
    var alloc_buffer: [14000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&alloc_buffer);
    const allocator = fba.allocator();

    var buffer = std.ArrayList(i32).init(allocator);
    defer buffer.deinit();

    var it = std.mem.splitScalar(u8, line, ' ');
    var i: u32 = 0;
    while (it.next()) |item| {
        const int = try std.fmt.parseInt(i32, item, 10);
        try buffer.append(int);
        i += 1;
    }
    const len = i;

    var sign_errors = std.ArrayList(u8).init(allocator);
    defer sign_errors.deinit();

    var bigger3_errors = std.ArrayList(u8).init(allocator);
    defer bigger3_errors.deinit();

    var noslope_errors = std.ArrayList(u8).init(allocator);
    defer noslope_errors.deinit();

    var sign: i8 = 0;
    if (buffer.items[0] > buffer.items[1]) {
        sign = -1;
    } else {
        sign = 1;
    }
    for (buffer.items, 0..) |item, j| {
        if (j == len - 1) break;
        const x = buffer.items[j];
        const y = buffer.items[j + 1];
        _ = item;
        if (@abs(x - y) > 3) {
            try bigger3_errors.append(1);
        } else {
            try bigger3_errors.append(0);
        }

        if (@abs(x - y) == 0) {
            try noslope_errors.append(1);
        } else {
            try noslope_errors.append(0);
        }

        var cur_sign: i8 = 0;
        if (x > y) {
            cur_sign = -1;
        } else {
            cur_sign = 1;
        }
        if (cur_sign != sign) {
            try sign_errors.append(1);
        } else {
            try sign_errors.append(0);
        }
    }
    var result: bool = true;
    for (buffer.items, 0..) |_, k| {
        std.debug.print("k: {d}\n", .{k});
        // remove element or execute on new slice without element
        const temp: i32 = buffer.orderedRemove(k);
        result = try is_safe3(buffer);
        try buffer.insert(k, temp);
        if (result) {
            break;
        }
    }
    return result;
}

pub fn calculate(filename: []const u8) !u128 {
    var result: u128 = 0;
    result += 0;
    const input = try std.fs.cwd().openFile(
        filename,
        .{ .mode = .read_only, .lock = .none },
    );
    defer input.close();

    var buffer: [140000]u8 = undefined;
    @memset(&buffer, 0);
    _ = try input.readAll(&buffer);
    var it = std.mem.splitScalar(u8, &buffer, '\n');

    while (it.next()) |line| {
        if (it.peek() == null) {
            break;
        }
        const safe = try is_safe(line);
        if (safe) {
            result += 1;
            std.debug.print("{s} Safe\n", .{line});
        } else {
            std.debug.print("{s} Unsafe\n", .{line});
        }
    }
    return result;
}

pub fn calculate2(filename: []const u8) !u128 {
    var result: u128 = 0;
    result += 0;
    const input = try std.fs.cwd().openFile(
        filename,
        .{ .mode = .read_only, .lock = .none },
    );
    defer input.close();

    var buffer: [140000]u8 = undefined;
    @memset(&buffer, 0);
    _ = try input.readAll(&buffer);
    var it = std.mem.splitScalar(u8, &buffer, '\n');

    while (it.next()) |line| {
        if (it.peek() == null) {
            break;
        }
        const safe = try is_safe2(line);
        if (safe) {
            result += 1;
            std.debug.print("{s} Safe\n", .{line});
        } else {
            std.debug.print("{s} Unsafe\n", .{line});
        }
    }
    return result;
}

pub fn main() !void {
    var result: u128 = 0;
    const filename = "input";
    result = try calculate(filename);

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Result for 1: {d}\n", .{result});

    result = try calculate2(filename);
    try stdout.print("Result for 2: {d}\n", .{result});

    try bw.flush(); // don't forget to flush!
}

test "initial test" {
    var result: u128 = 0;

    const filename = "sampleinput";
    result = try calculate(filename);

    //std.debug.print("result: {d}", .{result});
    try expect(result == 2);
}

test "is safe 1" {
    var result: bool = false;
    const line = "7 6 4 2 1";
    result = try is_safe(line);
    try expect(result == true);
}

test "is no safe 1" {
    var result: bool = true;
    const line = "9 7 6 2 1";
    result = try is_safe(line);
    try expect(result == false);
}

test "is safe 2" {
    var result: bool = false;
    const line = "1 3 6 7 9";
    result = try is_safe(line);
    try expect(result == true);
}

test "is safe second stage 1" {
    var result: bool = false;
    const line = "1 3 2 4 5";
    result = try is_safe2(line);
    try expect(result == true);
}

test "is safe second stage 2" {
    var result: bool = false;
    const line = "8 6 4 4 1";
    result = try is_safe2(line);
    try expect(result == true);
}

test "is safe second stage 3" {
    var result: bool = false;
    const line = "9 6 3 4 1";
    result = try is_safe2(line);
    try expect(result == true);
}

test "is safe second stage 4" {
    var result: bool = false;
    const line = "39 42 41 44 47";
    result = try is_safe2(line);
    try expect(result == true);
}

test "is safe second stage 5" {
    var result: bool = false;
    const line = "48 46 47 49 51 54 56";
    result = try is_safe2(line);
    try expect(result == true);
}

test "is unsafe second stage 1" {
    var result: bool = true;
    const line = "1 2 7 8 9";
    result = try is_safe2(line);
    try expect(result == false);
}

test "is unsafe second stage 2" {
    var result: bool = true;
    const line = "9 7 6 2 1";
    result = try is_safe2(line);
    try expect(result == false);
}

test "is unsafe second stage 3" {
    var result: bool = true;
    const line = "5 4 3 4 5";
    result = try is_safe2(line);
    try expect(result == false);
}

test "is unsafe second stage 4" {
    var result: bool = true;
    const line = "9 8 7 6 1";
    result = try is_safe2(line);
    try expect(result == false);
}

test "is unsafe second stage 5" {
    var result: bool = true;
    const line = "9 8 8 8 1";
    result = try is_safe2(line);
    try expect(result == false);
}

test "is unsafe second stage 6" {
    var result: bool = true;
    const line = "9 7 5 5 1";
    result = try is_safe2(line);
    try expect(result == false);
}

test "second stage test" {
    std.debug.print("Second stage test\n", .{});
    var result: u128 = 0;

    const filename = "sampleinput";
    result = try calculate2(filename);

    std.debug.print("result: {d}\n", .{result});
    try expect(result == 4);
}

test "second stage test 2" {
    std.debug.print("Second stage test\n", .{});
    var result: u128 = 0;

    const filename = "safe";
    result = try calculate2(filename);

    std.debug.print("result: {d}\n", .{result});
    try expect(result == 10);
}
