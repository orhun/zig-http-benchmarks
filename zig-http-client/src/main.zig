// Zig version: 0.11.0

const std = @import("std");
const http = std.http;

pub fn main() !void {
    // Create an allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Create an HTTP client.
    var client = http.Client{ .allocator = allocator };
    // Release all associated resources with the client.
    defer client.deinit();

    // Parse the URI.
    const uri = std.Uri.parse("http://127.0.0.1:8000/get") catch unreachable;

    // Create the headers that will be sent to the server.
    var headers = std.http.Headers{ .allocator = allocator };
    defer headers.deinit();

    // Accept anything.
    try headers.append("accept", "*/*");
    // Enable connection keep-alive.
    try headers.append("connection", "keep-alive");

    var i: usize = 0;

    while (i < 1000) : (i += 1) {
        // Make the connection to the server.
        var request = try client.request(.GET, uri, headers, .{});
        defer request.deinit();

        // Send the request and headers to the server.
        try request.start();

        // Wait for the server to send use a response
        try request.wait();

        // Read the entire response body, but only allow it to allocate 8KB of memory.
        const body = request.reader().readAllAlloc(allocator, 8192) catch unreachable;
        defer allocator.free(body);

        // Print out the response.
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{} {s}\n", .{i, body});
    }
}
