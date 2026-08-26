// Generate a Bootstrap Return message and dump the bytes
#include <capnp/rpc.capnp.h>
#include <capnp/message.h>
#include <capnp/serialize.h>
#include <iostream>
#include <iomanip>

int main() {
    // Create a message builder
    capnp::MallocMessageBuilder message;

    // Initialize the root Message as a Return
    auto rpcMessage = message.initRoot<capnp::rpc::Message>();
    auto ret = rpcMessage.initReturn();

    // Set Return fields
    ret.setAnswerId(0);
    ret.setReleaseParamCaps(true);

    // Initialize results (Payload)
    auto payload = ret.initResults();

    // Set up capability table with one senderHosted entry
    auto capTable = payload.initCapTable(1);
    capTable[0].setSenderHosted(1);  // Export ID = 1

    // Serialize and dump bytes
    auto words = capnp::messageToFlatArray(message);
    auto bytes = words.asBytes();

    std::cout << "Bootstrap Return message: " << bytes.size() << " bytes\n";
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
        std::cout << "W" << i << ": 0x" << std::hex << std::setfill('0')
                  << std::setw(16) << word << "\n";
    }

    return 0;
}
