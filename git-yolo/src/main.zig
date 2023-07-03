const std = @import("std");
const http = std.http;

// URL for fetching a random message.
const RANDOM_MESSAGE_URL = "https://whatthecommit.com/index.txt";

/// Returns a random message.
fn getRandomMessage(allocator: std.mem.Allocator) ![]u8 {
    // Create an HTTP client.
    var client = http.Client{ .allocator = allocator };
    // Release all associated resources with the client.
    defer client.deinit();
    // Parse the URI.
    const uri = try std.Uri.parse(RANDOM_MESSAGE_URL);
    // Create the headers that will be sent to the server.
    var headers = std.http.Headers{ .allocator = allocator };
    defer headers.deinit();
    // Accept anything.
    try headers.append("accept", "*/*");
    // Make the connection to the server.
    var request = try client.request(.GET, uri, headers, .{});
    defer request.deinit();
    // Send the request and headers to the server.
    try request.start();
    // Wait for the server to send use a response
    try request.wait();
    // Return the body.
    return try request.reader().readAllAlloc(allocator, 8192);
}

/// Executes the `git commit` command with the given message parameter.
fn commit(allocator: std.mem.Allocator, message: []const u8) !void {
    var process = std.ChildProcess.init(&[_][]const u8{
        "git",
        "commit",
        "-m",
        message,
    }, allocator);
    try process.spawn();
}

/// Entry-point of the application.
pub fn main() !void {
    // Create an allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    // Get a random message.
    var message = try getRandomMessage(allocator);
    defer allocator.free(message);
    // Create a git commit.
    try commit(allocator, message);
}
