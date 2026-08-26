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

    // Test 3: Multiply request
    {
        auto request = calculator.multiplyRequest();
        request.setLeft(6.0);
        request.setRight(7.0);

        std::cout << "Sending multiply(6, 7) request..." << std::endl;

        auto promise = request.send();
        auto response = promise.wait(waitScope);
        auto result = response.getValue();

        std::cout << "Multiply result: " << result;
        if (result == 42.0) {
            std::cout << " ✓ CORRECT" << std::endl;
        } else {
            std::cout << " ✗ WRONG (expected 42.0)" << std::endl;
            all_passed = false;
        }
    }

    // Test 4: Divide request
    {
        auto request = calculator.divideRequest();
        request.setLeft(100.0);
        request.setRight(4.0);

        std::cout << "Sending divide(100, 4) request..." << std::endl;

        auto promise = request.send();
        auto response = promise.wait(waitScope);
        auto result = response.getValue();

        std::cout << "Divide result: " << result;
        if (result == 25.0) {
            std::cout << " ✓ CORRECT" << std::endl;
        } else {
            std::cout << " ✗ WRONG (expected 25.0)" << std::endl;
            all_passed = false;
        }
    }

    // Test 5: Divide by zero - should throw exception
    {
        auto request = calculator.divideRequest();
        request.setLeft(10.0);
        request.setRight(0.0);

        std::cout << "Sending divide(10, 0) request (expect exception)..." << std::endl;

        try {
            auto promise = request.send();
            auto response = promise.wait(waitScope);
            // If we get here, the exception wasn't thrown
            std::cout << "Divide by zero: ✗ WRONG (expected exception)" << std::endl;
            all_passed = false;
        } catch (const kj::Exception& e) {
            std::cout << "Divide by zero exception: " << e.getDescription().cStr();
            std::cout << " ✓ CORRECT (exception thrown)" << std::endl;
        }
    }

    // Test 6: Get sub-calculator (T017 - Level 2 Promise Resolution)
    // With Level 2 Resolve message handling, this should now work
    {
        std::cout << "Sending getSubCalculator() request..." << std::endl;

        auto getSubRequest = calculator.getSubCalculatorRequest();
        auto getSubPromise = getSubRequest.send();
        auto getSubResponse = getSubPromise.wait(waitScope);
        auto subCalc = getSubResponse.getCalculator();

        std::cout << "Got sub-calculator, calling add(3, 4)..." << std::endl;

        auto addRequest = subCalc.addRequest();
        addRequest.setLeft(3.0);
        addRequest.setRight(4.0);
        auto addPromise = addRequest.send();
        auto addResponse = addPromise.wait(waitScope);
        auto result = addResponse.getValue();

        std::cout << "Sub-calculator add result: " << result;
        if (result == 7.0) {
            std::cout << " ✓ CORRECT" << std::endl;
        } else {
            std::cout << " ✗ WRONG (expected 7.0)" << std::endl;
            all_passed = false;
        }
    }

    // Test 7: Pipelined GetSubCalculator -> Add
    {
        std::cout << "Sending pipelined getSubCalculator()->add(5, 6)..." << std::endl;
        auto getSubRequest = calculator.getSubCalculatorRequest();
        // DO NOT WAIT. Immediately pipeline the call!
        auto subCalc = getSubRequest.send().getCalculator();
        
        auto addRequest = subCalc.addRequest();
        addRequest.setLeft(5.0);
        addRequest.setRight(6.0);
        auto addPromise = addRequest.send();
        auto addResponse = addPromise.wait(waitScope);
        auto result = addResponse.getValue();

        std::cout << "Pipelined sub-calculator add result: " << result;
        if (result == 11.0) {
            std::cout << " ✓ CORRECT" << std::endl;
        } else {
            std::cout << " ✗ WRONG (expected 11.0)" << std::endl;
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
