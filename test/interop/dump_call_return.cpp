// Generate a Call Return message (results with Float64) and dump the bytes
#include <capnp/rpc.capnp.h>
#include <capnp/message.h>
#include <capnp/serialize.h>
#include "../../example/calculator.capnp.h"
#include <iostream>
#include <iomanip>

int main() {
    // Create a message builder
    capnp::MallocMessageBuilder message;

    // Initialize the root Message as a Return
    auto rpcMessage = message.initRoot<capnp::rpc::Message>();
    auto ret = rpcMessage.initReturn();

    // Set Return fields
    ret.setAnswerId(1);  // Answer to question 1
    ret.setReleaseParamCaps(true);

    // Initialize results (Payload)
    auto payload = ret.initResults();

    // Set content as the result struct (Calculator.add result)
    // The result type is just { value :Float64 }
    auto content = payload.initContent();
    // Build a struct with Float64 value = 30.0
    capnp::MallocMessageBuilder resultBuilder;
    auto result = resultBuilder.initRoot<Calculator::AddResults>();
    result.setValue(30.0);

    // Copy the result into the content
    content.setAs<Calculator::AddResults>(result.asReader());

    // No capabilities in this result
    payload.initCapTable(0);

    // Serialize and dump bytes
    auto words = capnp::messageToFlatArray(message);
    auto bytes = words.asBytes();

    std::cout << "Call Return message: " << bytes.size() << " bytes\n";
    std::cout << "Hex dump:\n";

    for (size_t i = 0; i < bytes.size(); i++) {
        std::cout << std::hex << std::setfill('0') << std::setw(2)
                  << (int)bytes[i] << " ";
        if ((i + 1) % 8 == 0) std::cout << " | ";
        if ((i + 1) % 16 == 0) std::cout << "\n";
    }
    std::cout << std::dec << "\n";

    // Also dump as 64-bit words
    std::cout << "\nAs 64-bit words:\n";
    for (size_t i = 0; i < words.size(); i++) {
        uint64_t word = ((uint64_t*)words.begin())[i];
        std::cout << "W" << std::hex << i << ": 0x" << std::setfill('0')
                  << std::setw(16) << word << "\n";
    }

    return 0;
}
