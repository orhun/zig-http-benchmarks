#include <asio.hpp>
#include <iostream>

using asio::ip::tcp;

int main() {
  try {
    asio::io_context io_context;

    // Resolve the server address and port
    tcp::resolver resolver(io_context);
    tcp::resolver::results_type endpoints =
        resolver.resolve("localhost", "8000");

    // Create a socket and connect to the server
    tcp::socket socket(io_context);
    asio::connect(socket, endpoints);

    // Prepare the HTTP request
    std::string request = "GET /get HTTP/1.1\r\n"
                          "Host: localhost\r\n"
                          "Connection: close\r\n"
                          "\r\n";

    // Send the request to the server
    asio::write(socket, asio::buffer(request));

    // Read and print the response from the server
    asio::streambuf response_buffer;
    asio::read_until(socket, response_buffer,
                     "\r\n\r\n"); // Read until headers end
    std::istream response_stream(&response_buffer);

    // Print the response headers
    std::string header;
    while (std::getline(response_stream, header) && header != "\r")
      std::cout << header << std::endl;

    // Read and print the response content
    std::string content;
    if (response_buffer.size() > 0)
      content.assign(asio::buffers_begin(response_buffer.data()),
                     asio::buffers_end(response_buffer.data()));

    std::cout << "Response Content: " << content << std::endl;

    // Close the socket
    socket.close();
  } catch (const std::exception &e) {
    std::cerr << "Error: " << e.what() << std::endl;
  }

  return 0;
}
