#include "../../example/calculator.capnp.h"
#include <capnp/ez-rpc.h>
#include <capnp/message.h>
#include <kj/debug.h>
#include <iostream>

class CalculatorImpl final: public Calculator::Server {
public:
  kj::Promise<void> add(AddContext context) override {
    context.getResults().setValue(
        context.getParams().getLeft() + context.getParams().getRight());
    return kj::READY_NOW;
  }
  kj::Promise<void> subtract(SubtractContext context) override {
    context.getResults().setValue(
        context.getParams().getLeft() - context.getParams().getRight());
    return kj::READY_NOW;
  }
  kj::Promise<void> multiply(MultiplyContext context) override {
    context.getResults().setValue(
        context.getParams().getLeft() * context.getParams().getRight());
    return kj::READY_NOW;
  }
  kj::Promise<void> divide(DivideContext context) override {
    if (context.getParams().getRight() == 0) {
      return kj::Exception(kj::Exception::Type::FAILED,
                           __FILE__, __LINE__,
                           kj::str("Division by zero"));
    }
    context.getResults().setValue(
        context.getParams().getLeft() / context.getParams().getRight());
    return kj::READY_NOW;
  }
  kj::Promise<void> getSubCalculator(GetSubCalculatorContext context) override {
    context.getResults().setCalculator(kj::heap<CalculatorImpl>());
    return kj::READY_NOW;
  }
};

int main(int argc, const char* argv[]) {
  if (argc != 2) {
    std::cerr << "Usage: " << argv[0] << " BIND_ADDRESS" << std::endl;
    return 1;
  }
  
  try {
    capnp::EzRpcServer server(kj::heap<CalculatorImpl>(), argv[1]);
    auto& waitScope = server.getWaitScope();
    
    uint port = server.getPort().wait(waitScope);
    std::cout << "READY:" << port << std::endl;
    std::cout.flush();
    
    // Wait forever
    kj::NEVER_DONE.wait(waitScope);
  } catch (kj::Exception& e) {
    std::cerr << "KJ Exception: " << e.getDescription().cStr() << std::endl;
    return 1;
  }
  return 0;
}
