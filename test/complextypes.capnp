@0xd29d915c2929e377;

struct ComplexFields {
    dataField @0 :Data = 0x"deadbeef";
    listDataField @1 :List(Data) = [0x"11", 0x"22"];
    anyPointerField @2 :AnyPointer;
}
