const std = @import("std");
const mvzr = @import("mvzr");
const expect = std.testing.expect;

pub fn calculate(filename: []const u8) !u128 {
    var result: u128 = 0;
    result += 0;

    const input = try std.fs.cwd().openFile(
        filename,
        .{ .mode = .read_only, .lock = .none },
    );
    defer input.close();

    var haystack: [18000]u8 = undefined;
    @memset(&haystack, 0);

    _ = try input.readAll(&haystack);

    std.mem.replaceScalar(u8, &haystack, '\n', ' ');

    const dos: mvzr.Regex = mvzr.compile("do\\(\\)").?;
    const donts: mvzr.Regex = mvzr.compile("don't\\(\\)").?;

    var do_iter = dos.iterator(&haystack);
    var dont_iter = donts.iterator(&haystack);

    var do_pos: [18000]usize = undefined;
    @memset(&do_pos, 0);

    var dont_pos: [18000]usize = undefined;
    @memset(&dont_pos, 0);

    _ = .{ do_pos, dont_pos };

    var d: u8 = 0;
    while (do_iter.next()) |m| {
        std.debug.print("{s}\n", .{m});
        do_pos[d] = m.end;
        d += 1;
    }

    var t: u8 = 0;
    while (dont_iter.next()) |m| {
        std.debug.print("{s}\n", .{m});
        dont_pos[t] = m.start;
        t += 1;
    }

    const regex: mvzr.Regex = mvzr.compile("mul\\(\\d+,\\d+\\)").?;
    var iter = regex.iterator(&haystack);

    var sum: u128 = 0;
    const numbers: mvzr.Regex = mvzr.compile("\\d+").?;

    var d2: u8 = 0;
    var t2: u8 = 0;
    var disabled: bool = false;
    _ = .{ d2, t2 };
    while (iter.next()) |m| {
        if (!disabled and (m.start < dont_pos[t2] or dont_pos[t2] == 0)) {
            std.debug.print("Enabled, calculating! dont_pos[t2] {d}, do_pos[d2] {d} m {s}\n", .{ dont_pos[t2], do_pos[d2], m });
            var ite = numbers.iterator(m.slice);
            var mul: u128 = 1;
            while (ite.next()) |n| {
                mul *= try std.fmt.parseInt(u128, n.slice, 10);
            }
            sum += mul;
            // check if do_pos needs update
            if (m.start >= do_pos[d2]) {
                d2 += 1;
            }
            continue;
        } else if (!disabled and m.start >= dont_pos[t2] and dont_pos[t2] > 0) {
            std.debug.print("Disabling, not calculating! m.start {d} m {s}\n", .{ m.start, m });
            disabled = true;
            t2 += 1;
            continue;
        } else if (disabled and m.start < do_pos[d2] and do_pos[d2] > 0) {
            std.debug.print("Has been disabled, not calculating: m.start {d} m {s}\n", .{ m.start, m });
            // check if  dont_pos needs update
            if (m.start >= dont_pos[t2]) {
                t2 += 1;
            }
            continue;
        } else if (disabled and (m.start >= do_pos[d2] or do_pos[d2] == 0)) {
            std.debug.print("Enabling and calculatig! m.start {d} dopos[d2] {d} m {s}\n", .{ m.start, do_pos[d2], m });
            var ite = numbers.iterator(m.slice);
            var mul: u128 = 1;
            while (ite.next()) |n| {
                mul *= try std.fmt.parseInt(u128, n.slice, 10);
            }
            sum += mul;
            disabled = false;
            d2 += 1;
            continue;
        }
    }

    result = sum;
    return result;
}

pub fn main() !void {
    var result: u128 = 0;
    const filename = "input";
    result = try calculate(filename);

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Result: {d}\n", .{result});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var result: u128 = 0;

    const filename = "sampleinput2";
    result = try calculate(filename);

    try expect(result == 48);
}
