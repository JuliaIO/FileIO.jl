using FileIO
using ColorTypes
using ColorTypes.FixedPointNumbers
using Pkg
using Test

@testset "Integration" begin
    if haskey(ENV, "CI")
        Pkg.add(Base.VERSION >= v"1.3" ? "ImageIO" : "ImageMagick")
        img = rand(RGB{N0f8}, 50, 50)
        io = IOBuffer()
        save(Stream{format"PNG"}(io), img)
        buf = take!(io)
        io2 = IOBuffer(buf)
        img2 = load(io2)
        @test img2 == img
    end
end
