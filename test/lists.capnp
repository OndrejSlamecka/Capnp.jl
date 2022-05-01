@0xae6defd59403b31b;

struct ListTest {
  bytes @0 :List(UInt8);
  ints @1 :List(Int32);
#  bools @2 :List(Bool);
#  texts @3 :List(Text);
#  lists @4 :List(List(Int32));
}
