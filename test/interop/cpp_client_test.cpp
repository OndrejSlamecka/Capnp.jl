// C++ client test for Julia Cap'n Proto RPC server interoperability (T081)
// This tests SC-004: C++ client works with Julia calculator server

#include "../../example/calculator.capnp.h"
#include <capnp/ez-rpc.h>
#include <capnp/message.h>
#include <kj/debug.h>
#include <iostream>

int main(int argc, const char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " HOST:PORT" << std::endl;
        return 1;
    }

    // Connect to the server
    capnp::EzRpcClient client(argv[1]);
    auto& waitScope = client.getWaitScope();

    // Get the calculator capability
    Calculator::Client calculator = client.getMain<Calculator>();

    std::cout << "Connected to Julia calculator server at " << argv[1] << std::endl;

    bool all_passed = true;

    // Test 1: Add request
    {
        auto request = calculator.addRequest();
        request.setLeft(10.0);
        request.setRight(20.0);

        std::cout << "Sending add(10, 20) request..." << std::endl;

        auto promise = request.send();
        auto response = promise.wait(waitScope);
        auto result = response.getValue();

        std::cout << "Add result: " << result;
        if (result == 30.0) {
            std::cout << " ✓ CORRECT" << std::endl;
        } else {
            std::cout << " ✗ WRONG (expected 30.0)" << std::endl;
            all_passed = false;
        }
    }

    // Test 2: Subtract request
    {
        auto request = calculator.subtractRequest();
        request.setLeft(50.0);
        request.setRight(8.0);

        std::cout << "Sending subtract(50, 8) request..." << std::endl;

        auto promise = request.send();
        auto response = promise.wait(waitScope);
        auto result = response.getValue();

        std::cout << "Subtract result: " << result;
        if (result == 42.0) {
            std::cout << " ✓ CORRECT" << std::endl;
        } else {
            std::cout << " ✗ WRONG (expected 42.0)" << std::endl;
            all_passed = false;
        }
    }

    if (all_passed) {
        std::cout << "SUCCESS: All tests passed!" << std::endl;
        std::cout << "SC-004 VERIFIED: C++ client works with Julia calculator server" << std::endl;
        return 0;
    } else {
        std::cout << "FAILURE: Some tests failed" << std::endl;
        return 1;
    }
}
