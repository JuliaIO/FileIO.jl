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

    function Base.show(io::IO, m::MIME"text/html", data::MimeSaveTestType)
        content = read(joinpath(@__DIR__, "files", "mimesavetest.html"))
        write(io, content)
    end

    data = MimeSaveTestType()

    # Test with string and paths
    for output_filename in (tempname(), tmpname())
        for filetype in [".svg", ".pdf", ".eps", ".png", ".html"]

            try
                save(output_filename * filetype, data)

                content_original = read(joinpath(@__DIR__, "files", "mimesavetest$filetype"))
                content_new = read(output_filename * filetype)

                @test content_new == content_original
            finally
                isfile(output_filename * filetype) && rm(output_filename * filetype)
            end

            # Functional form
            data |> save(output_filename * filetype)
            try
                content_original = read(joinpath(@__DIR__, "files", "mimesavetest$filetype"))
                content_new = read(output_filename * filetype)

                @test content_new == content_original
            finally
                rm(output_filename * filetype)
            end

        end
    end

end
