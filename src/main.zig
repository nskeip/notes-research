const std = @import("std");
const assert = std.debug.assert;

// 0. make convenient way to read numbers from 0 to 11
// 1. take 36 chords
// 2. take 24 scales
// 3. for every chord make a list of scales it lives in.
// 4. for every scale show how it intersects with every other scale.

fn majorScaleFromN(n: u8) [7]u8 {
    assert(n < 12);

    const c = n;
    const d = (c + 2) % 12;
    const e = (d + 2) % 12;
    const f = (e + 1) % 12;
    const g = (f + 2) % 12;
    const a = (g + 2) % 12;
    const b = (a + 2) % 12;

    return [7]u8{ c, d, e, f, g, a, b };
}

fn minorScaleFromN(n: u8) [7]u8 {
    assert(n < 12);

    const a = n;
    const b = (a + 2) % 12;
    const c = (b + 1) % 12;
    const d = (c + 2) % 12;
    const e = (d + 2) % 12;
    const f = (e + 1) % 12;
    const g = (f + 2) % 12;

    return [7]u8{ a, b, c, d, e, f, g };
}

fn majorChordFromN(n: u8) [3]u8 {
    const scale = majorScaleFromN(n);
    return [3]u8{ scale[0], scale[2], scale[4] };
}

fn minorChordFromN(n: u8) [3]u8 {
    const scale = minorScaleFromN(n);
    return [3]u8{ scale[0], scale[2], scale[4] };
}

fn dimChordFromN(n: u8) [3]u8 {
    const scale = majorScaleFromN(n);
    const b = scale[6];
    const d = scale[1];
    const f = scale[3];
    return [3]u8{ b, d, f };
}

fn printNote(w: anytype, note: u8) !void {
    switch (note) {
        0 => try w.print("C", .{}),
        1 => try w.print("C#", .{}),
        2 => try w.print("D", .{}),
        3 => try w.print("D#", .{}),
        4 => try w.print("E", .{}),
        5 => try w.print("F", .{}),
        6 => try w.print("F#", .{}),
        7 => try w.print("G", .{}),
        8 => try w.print("G#", .{}),
        9 => try w.print("A", .{}),
        10 => try w.print("A#", .{}),
        11 => try w.print("B", .{}),
        else => unreachable,
    }
}

fn printChord(w: anytype, chord: [3]u8) !void {
    try w.print("[", .{});
    try printNote(w, chord[0]);
    try w.print(" ", .{});
    try printNote(w, chord[1]);
    try w.print(" ", .{});
    try printNote(w, chord[2]);
    try w.print("]", .{});
}

fn printScale(w: anytype, scale: [7]u8) !void {
    try w.print("[", .{});
    for (scale) |note| {
        try printNote(w, note);
        try w.print(" ", .{});
    }
    try w.print("]", .{});
}

fn noteIsInScale(note: u8, scale: [7]u8) bool {
    for (scale) |scaleNote| {
        if (note == scaleNote) {
            return true;
        }
    }
    return false;
}

fn chordIsInScale(chord: [3]u8, scale: [7]u8) bool {
    return noteIsInScale(chord[0], scale) and noteIsInScale(chord[1], scale) and noteIsInScale(chord[2], scale);
}

pub fn main() !void {
    const stdout = std.io.getStdOut();
    var w = stdout.writer();

    try w.print("Running through all major/minor scales.\n", .{});

    for (0..12) |big_n| {
        const n: u8 = @truncate(big_n);

        {
            try w.print("Chord: ", .{});
            try printNote(w, n);
            try w.print(" major ", .{});
            const majorChord = majorChordFromN(n);
            try printChord(w, majorChord);
            try w.print("\n", .{});

            try w.print("Met in major scales:\n", .{});
            for (0..12) |big_m| {
                const m: u8 = @truncate(big_m);
                const scale = majorScaleFromN(m);
                if (chordIsInScale(majorChord, scale)) {
                    try w.print("  ", .{});
                    try printNote(w, m);
                    try w.print("  ", .{});
                    try printScale(w, scale);
                    try w.print("\n", .{});
                }
            }

            try w.print("Met in minor scales:\n", .{});
            for (0..12) |big_m| {
                const m: u8 = @truncate(big_m);
                const scale = minorScaleFromN(m);
                if (chordIsInScale(majorChord, scale)) {
                    try w.print("  ", .{});
                    try printNote(w, m);
                    try w.print("  ", .{});
                    try printScale(w, scale);
                    try w.print("\n", .{});
                }
            }
        }

        {
            try w.print("Chord: ", .{});
            try printNote(w, n);
            try w.print(" minor ", .{});
            const minorChord = minorChordFromN(n);
            try printChord(w, minorChord);
            try w.print("\n", .{});

            try w.print("Met in major scales:\n", .{});
            for (0..12) |big_m| {
                const m: u8 = @truncate(big_m);
                const scale = majorScaleFromN(m);
                if (chordIsInScale(minorChord, scale)) {
                    try w.print("  ", .{});
                    try printNote(w, m);
                    try w.print("  ", .{});
                    try printScale(w, scale);
                    try w.print("\n", .{});
                }
            }

            try w.print("Met in minor scales:\n", .{});
            for (0..12) |big_m| {
                const m: u8 = @truncate(big_m);
                const scale = minorScaleFromN(m);
                if (chordIsInScale(minorChord, scale)) {
                    try w.print("  ", .{});
                    try printNote(w, m);
                    try w.print("  ", .{});
                    try printScale(w, scale);
                    try w.print("\n", .{});
                }
            }
        }

        try w.print("--------------------------\n", .{});
    }
}

test "C major scale" {
    const scale = majorScaleFromN(0);
    try std.testing.expectEqual([7]u8{ 0, 2, 4, 5, 7, 9, 11 }, scale);
}

test "C minor scale" {
    const scale = minorScaleFromN(0);
    try std.testing.expectEqual([7]u8{ 0, 2, 3, 5, 7, 8, 10 }, scale);
}

test "A major scale" {
    const scale = majorScaleFromN(9);
    try std.testing.expectEqual([7]u8{ 9, 11, 1, 2, 4, 6, 8 }, scale);
}

test "A minor scale" {
    const scale = minorScaleFromN(9);
    try std.testing.expectEqual([7]u8{ 9, 11, 0, 2, 4, 5, 7 }, scale);
}

test "F# is not in C major scale" {
    const scale = majorScaleFromN(0);
    try std.testing.expect(!noteIsInScale(6, scale));
}

test "C major chord is in C major scale" {
    const scale = majorScaleFromN(0);
    const chord = majorChordFromN(0);
    try std.testing.expect(chordIsInScale(chord, scale));
}
