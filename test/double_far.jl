using Capnp
using Test

@testset "Double Far Pointer validation" begin
    seg1 = zeros(UInt8, 8)
    seg2 = zeros(UInt8, 16)
    seg3 = zeros(UInt8, 8)
    
    # Segment 3 has a struct of size 1 word data
    seg3[1] = 42
    
    # Segment 2 has the landing pad (B=1)
    # First word: far pointer to Segment 3, offset 0
    A = Int64(0b10)
    B = Int64(0)
    C = Int64(0)
    D = Int64(2) # segment 3
    bytes1 = (D << 32) | (C << 3) | (B << 2) | A
    Capnp._checked_store!(Capnp._checked_segment([seg1, seg2, seg3], 2), 0, bytes1)
    
    # Second word: struct pointer with offset 0
    # struct pointer: lsb 2 bits = 0, offset = 0, data words = 1, ptr words = 0
    struct_bytes = Int64(1) << 32
    Capnp._checked_store!(Capnp._checked_segment([seg1, seg2, seg3], 2), 8, struct_bytes)
    
    # Segment 1 has the far pointer to Segment 2 (B=1)
    # double far pointer: A=0b10, B=1, C=offset in seg2 (0), D=segment 2
    A3 = Int64(0b10)
    B3 = Int64(1)
    C3 = Int64(0)
    D3 = Int64(1)
    bytes3 = (D3 << 32) | (C3 << 3) | (B3 << 2) | A3
    Capnp._checked_store!(Capnp._checked_segment([seg1, seg2, seg3], 1), 0, bytes3)
    
    # MessageReader requires an IO, so we create a dummy one and override segments
    reader = Capnp.MessageReader(IOBuffer(UInt8[0,0,0,0, 0,0,0,0]))
    reader.segments = [seg1, seg2, seg3]
    
    # Construct a dummy struct pointer for the root (segment 1, offset 0)
    # and read pointer 0
    fake_root = Capnp.StructPointer(reader, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
    struct_read = Capnp.read_struct_pointer(fake_root, 0, 0)
    
    @test struct_read.segment == 3
    @test struct_read.offset == 0
    @test struct_read.data_word_count == 1
    @test struct_read.pointer_count == 0
end

@testset "Double Far Pointer strict validation" begin
    seg1 = zeros(UInt8, 8)
    seg2 = zeros(UInt8, 16)
    seg3 = zeros(UInt8, 8)
    
    A = Int64(0b10)
    B = Int64(0)
    C = Int64(0)
    D = Int64(2)
    bytes1 = (D << 32) | (C << 3) | (B << 2) | A
    Capnp._checked_store!(Capnp._checked_segment([seg1, seg2, seg3], 2), 0, bytes1)
    
    # Second word: struct pointer with non-zero offset (INVALID!)
    # offset = 1 -> bits 2-31 = 1 << 2
    struct_bytes = (Int64(1) << 32) | (Int64(1) << 2)
    Capnp._checked_store!(Capnp._checked_segment([seg1, seg2, seg3], 2), 8, struct_bytes)
    
    A3 = Int64(0b10)
    B3 = Int64(1)
    C3 = Int64(0)
    D3 = Int64(1)
    bytes3 = (D3 << 32) | (C3 << 3) | (B3 << 2) | A3
    Capnp._checked_store!(Capnp._checked_segment([seg1, seg2, seg3], 1), 0, bytes3)
    
    reader = Capnp.MessageReader(IOBuffer(UInt8[0,0,0,0, 0,0,0,0]))
    reader.segments = [seg1, seg2, seg3]
    fake_root = Capnp.StructPointer(reader, UInt32(1), UInt32(0), UInt16(0), UInt16(1))
    
    @test_throws Capnp.InvalidMessageError Capnp.read_struct_pointer(fake_root, 0, 0)
end
