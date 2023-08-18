#include <iostream>
#include <string>
#include <server_http.hpp>

using HttpServer = SimpleWeb::Server<SimpleWeb::HTTP>;

int main() {
    // Create the HTTP server
    HttpServer server;
    server.config.port = 8000;
    
    // Define the request handler
    server.resource["^/get$"]["GET"] = [](std::shared_ptr<HttpServer::Response> response, std::shared_ptr<HttpServer::Request> request) {
        std::string content = "C++ Bits!\n";
        *response << "HTTP/1.1 200 OK\r\nContent-Length: " << content.length() << "\r\n\r\n" << content;
    };
    
    // Start the server
    std::cout << "Server started on port 8000." << std::endl;
    server.start();
    
    return 0;
}
