#include <asio.hpp>
#include <chrono>
#include <iostream>
#include <memory>
#include <thread>
#include <vector>

using asio::ip::tcp;

class HttpClient {
public:
  HttpClient(asio::io_context &ioContext)
      : ioContext_(ioContext), socket_(ioContext) {}

  void connect(const std::string &host, const std::string &port) {
    tcp::resolver resolver(ioContext_);
    endpoints_ = resolver.resolve(host, port);
    asio::connect(socket_, endpoints_);
  }

  void sendRequest(const std::string &request,
                   std::function<void(const std::string &)> onResponse) {
    onResponse_ = std::move(onResponse);
    asio::async_write(socket_, asio::buffer(request),
                      [this](std::error_code ec, std::size_t /*length*/) {
                        if (!ec) {
                          readResponse();
                        } else {
                          std::cerr << "Write error: " << ec.message()
                                    << std::endl;
                        }
                      });
  }

  void readResponse() {
    asio::async_read_until(socket_, responseBuffer_, "\r\n\r\n",
                           [this](std::error_code ec, std::size_t /*length*/) {
                             if (!ec) {
                               processResponse();
                             } else {
                               std::cerr << "Read error: " << ec.message()
                                         << std::endl;
                             }
                           });
  }

  void processResponse() {
    std::istream responseStream(&responseBuffer_);

    std::string header;
    while (std::getline(responseStream, header) && header != "\r") {
      std::cout << header << std::endl;
    }

    std::ostringstream contentStream;
    if (responseBuffer_.size() > 0) {
      contentStream << &responseBuffer_;
      onResponse_(contentStream.str());
    }

    socket_.close();
  }

private:
  asio::io_context &ioContext_;
  tcp::socket socket_;
  tcp::resolver::results_type endpoints_;
  asio::streambuf responseBuffer_;
  std::function<void(const std::string &)> onResponse_;
};

int main() {
  try {
    asio::io_context ioContext;

    const std::string host = "localhost";
    const std::string port = "8000";

    std::vector<std::unique_ptr<HttpClient>> clients;
    std::vector<std::string> responses;

    for (int i = 0; i < 1000; ++i) {
      clients.emplace_back(std::make_unique<HttpClient>(ioContext));
      clients.back()->connect(host, port);
      clients.back()->sendRequest(
          "GET /get HTTP/1.1\r\n"
          "Host: localhost\r\n"
          "Connection: keep-alive\r\n"
          "\r\n",
          [&](const std::string &response) { responses.push_back(response); });
    }

    ioContext.run();

    // Process responses as needed
    for (const auto &response : responses) {
      std::cout << "Response Content: " << response << std::endl;
    }
  } catch (const std::exception &e) {
    std::cerr << "Error: " << e.what() << std::endl;
  }

  return 0;
}
