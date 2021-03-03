using FileIO
using ColorTypes
using ColorTypes.FixedPointNumbers
using Test

@testset "Integration" begin
    img = rand(RGB{N0f8}, 50, 50)
    io = IOBuffer()
    save(Stream{format"PNG"}(io), img)
    buf = take!(io)
    io2 = IOBuffer(buf)
    img2 = load(io2)
    @test img2 == img
end
