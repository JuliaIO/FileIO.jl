using FileIO
using Test

@testset "Mime save" begin

function Base.show(io::IO, m::MIME"image/svg+xml", data::MimeSaveTestType)
    content = read(joinpath(@__DIR__, "files", "mimesavetest.svg"))
    write(io, content)
end

function Base.show(io::IO, m::MIME"application/pdf", data::MimeSaveTestType)
    content = read(joinpath(@__DIR__, "files", "mimesavetest.pdf"))
    write(io, content)
end

function Base.show(io::IO, m::MIME"application/eps", data::MimeSaveTestType)
    content = read(joinpath(@__DIR__, "files", "mimesavetest.eps"))
    write(io, content)
end

function Base.show(io::IO, m::MIME"image/png", data::MimeSaveTestType)
    content = read(joinpath(@__DIR__, "files", "mimesavetest.png"))
    write(io, content)
end

data = MimeSaveTestType()

output_filename = tempname()

for filetype in [".svg", ".pdf", ".eps", ".png"]

    try
        save(output_filename * filetype, data)

        content_original = read(joinpath(@__DIR__, "files", "mimesavetest$filetype"))
        content_new = read(output_filename * filetype)

        @test content_new == content_original
    finally
        isfile(output_filename * filetype) && rm(output_filename * filetype)
    end

end

end
