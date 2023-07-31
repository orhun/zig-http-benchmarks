const std = @import("std");
const http = std.http;
const log = std.log.scoped(.server);

const server_addr = "127.0.0.1";
const server_port = 8000;

// Run the server and handle incoming requests.
fn runServer(server: *http.Server, allocator: std.mem.Allocator) !void {
    outer: while (true) {
        // Accept incoming connection.
        var response = try server.accept(.{
            .allocator = allocator,
        });
        defer response.deinit();

        // Avoid Nagle's algorithm.
        // <https://en.wikipedia.org/wiki/Nagle%27s_algorithm>
        try std.os.setsockopt(
            response.connection.stream.handle,
            std.os.IPPROTO.TCP,
            std.os.TCP.NODELAY,
            &std.mem.toBytes(@as(c_int, 1)),
        );

        while (response.reset() != .closing) {
            // Handle errors during request processing.
            response.wait() catch |err| switch (err) {
                error.HttpHeadersInvalid => continue :outer,
                error.EndOfStream => continue,
                else => return err,
            };

            // Process the request.
            try handleRequest(&response, allocator);
        }
    }
}

// Handle an individual request.
fn handleRequest(response: *http.Server.Response, allocator: std.mem.Allocator) !void {
    // Log the request details.
    log.info("{s} {s} {s}", .{ @tagName(response.request.method), @tagName(response.request.version), response.request.target });

    // Read the request body.
    const body = try response.reader().readAllAlloc(allocator, 8192);
    defer allocator.free(body);

    // Set "connection" header to "keep-alive" if present in request headers.
    if (response.request.headers.contains("connection")) {
        try response.headers.append("connection", "keep-alive");
    }

    // Check if the request target starts with "/get".
    if (std.mem.startsWith(u8, response.request.target, "/get")) {
        // Check if the request target contains "?chunked".
        if (std.mem.indexOf(u8, response.request.target, "?chunked") != null) {
            response.transfer_encoding = .chunked;
        } else {
            response.transfer_encoding = .{ .content_length = 10 };
        }

        // Set "content-type" header to "text/plain".
        try response.headers.append("content-type", "text/plain");

        // Write the response body.
        try response.do();
        if (response.request.method != .HEAD) {
            try response.writeAll("Zig Bits!\n");
            try response.finish();
        }
    } else {
        // Set the response status to 404 (not found).
        response.status = .not_found;
        try response.do();
    }
}

pub fn main() !void {
    // Create an allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Initialize the server.
    var server = http.Server.init(allocator, .{ .reuse_address = true });
    defer server.deinit();

    // Log the server address and port.
    log.info("Server is running at {s}:{d}", .{ server_addr, server_port });

    // Parse the server address.
    const address = std.net.Address.parseIp(server_addr, server_port) catch unreachable;
    try server.listen(address);

    // Run the server.
    runServer(&server, allocator) catch |err| {
        // Handle server errors.
        log.err("server error: {}\n", .{err});
        if (@errorReturnTrace()) |trace| {
            std.debug.dumpStackTrace(trace.*);
        }
        std.os.exit(1);
    };
}
