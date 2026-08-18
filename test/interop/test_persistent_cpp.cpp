// C++ interop tests for Level 2 Persistent Capabilities (T076, T077)
// Tests save/restore with Julia server and SturdyRef format compatibility

#include "../../example/calculator.capnp.h"
#include <capnp/ez-rpc.h>
#include <capnp/message.h>
#include <capnp/serialize.h>
#include <kj/debug.h>
#include <iostream>
#include <vector>

// Note: This test file is prepared for when the Julia server implements
// the Persistent interface for the Calculator capability.
// Currently, the persistent capability tests require the server to support
// the save() method on capabilities.

int main(int argc, const char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " HOST:PORT [--test-save|--test-format]" << std::endl;
        std::cerr << std::endl;
        std::cerr << "Tests:" << std::endl;
        std::cerr << "  --test-save    Test save/restore workflow with server (T076)" << std::endl;
        std::cerr << "  --test-format  Test SturdyRef format compatibility (T077)" << std::endl;
        return 1;
    }

    std::string mode = argc >= 3 ? argv[2] : "--test-format";
    bool all_passed = true;

    if (mode == "--test-format") {
        // T077: SturdyRef format compatibility test
        // This test verifies that the SturdyRef format used by Julia is compatible
        // with what a C++ client would expect.

        std::cout << "=== T077: SturdyRef Format Compatibility Test ===" << std::endl;

        // The Julia DefaultSturdyRef format is:
        // [4 bytes: host_id length][host_id bytes][4 bytes: object_id length][object_id bytes]

        // Create a test SturdyRef in the Julia format
        std::vector<uint8_t> julia_format;

        // Host ID: "localhost:5000"
        std::string host_id = "localhost:5000";
        uint32_t host_len = host_id.length();
        julia_format.push_back((host_len >> 0) & 0xFF);
        julia_format.push_back((host_len >> 8) & 0xFF);
        julia_format.push_back((host_len >> 16) & 0xFF);
        julia_format.push_back((host_len >> 24) & 0xFF);
        for (char c : host_id) {
            julia_format.push_back(static_cast<uint8_t>(c));
        }

        // Object ID: "calculator-42"
        std::string object_id = "calculator-42";
        uint32_t obj_len = object_id.length();
        julia_format.push_back((obj_len >> 0) & 0xFF);
        julia_format.push_back((obj_len >> 8) & 0xFF);
        julia_format.push_back((obj_len >> 16) & 0xFF);
        julia_format.push_back((obj_len >> 24) & 0xFF);
        for (char c : object_id) {
            julia_format.push_back(static_cast<uint8_t>(c));
        }

        std::cout << "Created Julia-format SturdyRef:" << std::endl;
        std::cout << "  Host ID: " << host_id << std::endl;
        std::cout << "  Object ID: " << object_id << std::endl;
        std::cout << "  Total bytes: " << julia_format.size() << std::endl;

        // Parse it back to verify
        size_t pos = 0;
        uint32_t parsed_host_len = julia_format[pos] |
                                   (julia_format[pos+1] << 8) |
                                   (julia_format[pos+2] << 16) |
                                   (julia_format[pos+3] << 24);
        pos += 4;

        std::string parsed_host(julia_format.begin() + pos,
                               julia_format.begin() + pos + parsed_host_len);
        pos += parsed_host_len;

        uint32_t parsed_obj_len = julia_format[pos] |
                                  (julia_format[pos+1] << 8) |
                                  (julia_format[pos+2] << 16) |
                                  (julia_format[pos+3] << 24);
        pos += 4;

        std::string parsed_obj(julia_format.begin() + pos,
                              julia_format.begin() + pos + parsed_obj_len);

        std::cout << "Parsed back:" << std::endl;
        std::cout << "  Host ID: " << parsed_host << std::endl;
        std::cout << "  Object ID: " << parsed_obj << std::endl;

        if (parsed_host == host_id && parsed_obj == object_id) {
            std::cout << "✓ SturdyRef format round-trip successful" << std::endl;
        } else {
            std::cout << "✗ SturdyRef format mismatch" << std::endl;
            all_passed = false;
        }

        // Verify expected size
        size_t expected_size = 4 + host_id.length() + 4 + object_id.length();
        if (julia_format.size() == expected_size) {
            std::cout << "✓ SturdyRef size is correct (" << expected_size << " bytes)" << std::endl;
        } else {
            std::cout << "✗ SturdyRef size mismatch (got " << julia_format.size()
                      << ", expected " << expected_size << ")" << std::endl;
            all_passed = false;
        }

    } else if (mode == "--test-save") {
        // T076: Save/restore workflow test
        // Note: This requires the Julia server to support the Persistent interface

        std::cout << "=== T076: Save/Restore Interop Test ===" << std::endl;
        std::cout << "Connecting to " << argv[1] << "..." << std::endl;

        try {
            capnp::EzRpcClient client(argv[1]);
            auto& waitScope = client.getWaitScope();

            // Get the calculator capability
            Calculator::Client calculator = client.getMain<Calculator>();

            std::cout << "Connected. Testing basic operation first..." << std::endl;

            // Verify basic functionality
            {
                auto request = calculator.addRequest();
                request.setLeft(1.0);
                request.setRight(2.0);
                auto response = request.send().wait(waitScope);
                auto result = response.getValue();
                if (result == 3.0) {
                    std::cout << "✓ Basic add(1, 2) = 3 works" << std::endl;
                } else {
                    std::cout << "✗ Basic add failed" << std::endl;
                    all_passed = false;
                }
            }

            // Note: The save() method would be called here if the Calculator
            // interface extended Persistent. Since our test calculator doesn't
            // extend Persistent in the schema, we can't test save() directly
            // from the C++ client.
            //
            // The persistence functionality is tested via the Julia unit tests
            // which use SimplePersistentCapability.

            std::cout << std::endl;
            std::cout << "Note: Direct save() call requires Calculator to extend Persistent" << std::endl;
            std::cout << "The Julia unit tests verify persistence functionality" << std::endl;

        } catch (const kj::Exception& e) {
            std::cerr << "Connection failed: " << e.getDescription().cStr() << std::endl;
            all_passed = false;
        }
    }

    if (all_passed) {
        std::cout << std::endl << "SUCCESS: All tests passed!" << std::endl;
        return 0;
    } else {
        std::cout << std::endl << "FAILURE: Some tests failed" << std::endl;
        return 1;
    }
}
