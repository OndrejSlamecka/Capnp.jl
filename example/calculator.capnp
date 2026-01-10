# Calculator interface example for Cap'n Proto RPC
# This schema defines a simple calculator service for demonstrating RPC

@0xd4a5d7b5c8f7e6a3;

# A simple calculator interface
interface Calculator {
  # Add two numbers
  add @0 (left :Float64, right :Float64) -> (value :Float64);

  # Subtract two numbers
  subtract @1 (left :Float64, right :Float64) -> (value :Float64);

  # Multiply two numbers
  multiply @2 (left :Float64, right :Float64) -> (value :Float64);

  # Divide two numbers
  divide @3 (left :Float64, right :Float64) -> (value :Float64);

  # Get a sub-calculator (for demonstrating capability passing)
  getSubCalculator @4 () -> (calculator :Calculator);
}

# Parameter and result structs for explicit parameter handling
struct AddParams {
  left @0 :Float64;
  right @1 :Float64;
}

struct CalculatorResult {
  value @0 :Float64;
}
