@0xae6defd59403b31b;

struct ListTest {
  bytes @0 :List(UInt8);
  ints @1 :List(Int32);
#  bools @2 :List(Bool);
  texts @2 :List(Text);
  lists @3 :List(List(Int32));
  dataList @4 :List(Data);
}