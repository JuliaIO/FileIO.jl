using FileIO
using ColorTypes
using ColorTypes.FixedPointNumbers
using HTTP
using Pkg
using Test

@testset "Integration" begin
    if haskey(ENV, "CI") && Base.VERSION >= v"1.3"  # ImageIO can't be loaded on Julia < 1.3, so putting it as test dep is problematic
        Pkg.add("ImageIO")
        img = rand(RGB{N0f8}, 50, 50)
        io = IOBuffer()
        save(Stream{format"PNG"}(io), img)
        buf = take!(io)
        io2 = IOBuffer(buf)
        img2 = load(io2)
        @test img2 == img

        uri = HTTP.URI("https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Wikipedia-logo-v2-en.svg/135px-Wikipedia-logo-v2-en.svg.png")
        @test isa(load(uri), Matrix)
    end
end
