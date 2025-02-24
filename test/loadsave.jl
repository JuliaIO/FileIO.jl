using FileIO
using Test

# Stub readers---these might bork any existing readers, so don't
# run these tests while doing other things!
module TestLoadSave
    import FileIO: File, @format_str
    load(file::File{format"PBMText"})   = "PBMText"
    load(file::File{format"PBMBinary"}) = "PBMBinary"
    load(file::File{format"JLD"})       = "JLD"
    load(file::File{format"GZIP"})      = "GZIP"
end
module TestLoadSave2
    import FileIO: File, @format_str
    fileio_load(file::File{format"HDF5"})      = "HDF5"
    fileio_load(file::File{format"BIB"})       = "BIB"
    fileio_load(file::File{format"DCM"})       = "DCM"
end

@testset "FakeIO" begin
    sym2loader = copy(FileIO.sym2loader)
    sym2saver = copy(FileIO.sym2saver)

    try
        empty!(FileIO.sym2loader)
        empty!(FileIO.sym2saver)
        file_dir = joinpath(dirname(@__FILE__), "files")
        file_path = Path(file_dir)

        @testset "Load $(typeof(fp))" for fp in (file_dir, file_path)

            add_loader(format"PBMText", TestLoadSave)
            add_loader(format"PBMBinary", TestLoadSave)
            add_loader(format"HDF5", TestLoadSave2)
            add_loader(format"JLD", TestLoadSave)
            add_loader(format"GZIP", TestLoadSave)
            add_loader(format"BIB", TestLoadSave2)
            add_loader(format"DCM", TestLoadSave2)

            @test load(joinpath(fp,"file1.pbm")) == "PBMText"
            @test load(joinpath(fp,"file2.pbm")) == "PBMBinary"

            # Regular HDF5 file with magic bytes starting at position 0
            @test load(joinpath(fp,"file1.h5")) == "HDF5"
            # This one is actually a JLD file saved with an .h5 extension,
            # and the JLD magic bytes edited to prevent it from being recognized
            # as JLD.
            # JLD files are also HDF5 files, so this should be recognized as
            # HDF5. However, what makes this more interesting is that the
            # magic bytes start at position 512.
            @test load(joinpath(fp,"file2.h5")) == "HDF5"
            # JLD file saved with .jld extension
            @test load(joinpath(fp,"file.jld")) == "JLD"
            # GZIP file saved with .gz extension
            @test load(joinpath(fp,"file.csv.gz")) == "GZIP"
            # Bibliography file saved with .bib extension
            @test load(joinpath(fp,"file.bib")) == "BIB"
            # DICOM file saved with .dcm extension
            @test load(joinpath(fp,"CT_JPEG70.dcm")) == "DCM"
            @test_throws Exception load("missing.fmt")
        end
    finally
        empty!(FileIO.sym2loader)
        empty!(FileIO.sym2saver)
        merge!(FileIO.sym2loader, sym2loader)
        merge!(FileIO.sym2saver, sym2saver)
    end
end

# A tiny but complete example
# DUMMY format is:
#  - n, a single Int64
#  - a vector of length n of UInt8s

add_format(format"DUMMY", b"DUMMY", ".dmy")

module Dummy

    using FileIO

    mutable struct DummyReader{IOtype}
        stream::IOtype
        ownstream::Bool
        bytesleft::Int64
    end

    function DummyReader(stream, ownstream)
        read(stream, 5) == magic(format"DUMMY") || error("wrong magic bytes")
        DummyReader(stream, ownstream, read(stream, Int64))
    end

    function Base.read(stream::DummyReader, n=stream.bytesleft)
        toread = min(n, stream.bytesleft)
        buf = read(stream.stream, toread)
        stream.bytesleft -= length(buf)
        buf
    end

    Base.eof(stream::DummyReader) = stream.bytesleft == 0 || eof(stream.stream)
    Base.close(stream::DummyReader) = stream.ownstream && close(stream.stream)

    mutable struct DummyWriter{IOtype}
        stream::IOtype
        ownstream::Bool
        headerpos::Int64
        byteswritten::Int
    end

    function DummyWriter(stream, ownstream)
        write(stream, magic(format"DUMMY"))  # Write the magic bytes
        # store the position where we'll need to write the length
        pos = position(stream)
        # write a dummy length value
        write(stream, 0xffffffffffffffff)
        DummyWriter(stream, ownstream, pos, 0)
    end

    function Base.write(stream::DummyWriter, data)
        udata = convert(Vector{UInt8}, data)
        n = write(stream.stream, udata)
        stream.byteswritten += n

        n
    end

    function Base.close(stream::DummyWriter)
        here = position(stream.stream)
        # go back and write the header
        seek(stream.stream, stream.headerpos)
        write(stream.stream, convert(Int64, stream.byteswritten))
        seek(stream.stream, here)
        stream.ownstream && close(stream.stream)

        nothing
    end

    loadstreaming(s::Stream{format"DUMMY"}) = DummyReader(s, false)
    loadstreaming(file::File{format"DUMMY"}) = DummyReader(open(file), true)
    savestreaming(s::Stream{format"DUMMY"}) = DummyWriter(s, false)
    savestreaming(file::File{format"DUMMY"}) = DummyWriter(open(file, "w"), true)

    # we could implement `load` and `save` in terms of their streaming versions
    function load(file::File{format"DUMMY"}; extra=UInt8[])
        open(file) do s
            load(s; extra=extra)
        end
    end

    function metadata(file::File{format"DUMMY"})
        s = open(file)
        skipmagic(s)
        n = read(s, Int64)
        close(s)
        return n
    end

    function load(s::Stream{format"DUMMY"}; extra=UInt8[])
        skipmagic(s)
        n = read(s, Int64)
        out = Vector{UInt8}(undef, n)
        read!(s, out)
        # verify that the extradata is as expected. This is just to test that
        # the keyword arguments are handled properly in loading and saving
        extradata = read(s, length(extra))
        if extradata != extra
            throw(ErrorException("Got extra data $extradata instead of $extra"))
        end
        close(s)
        out
    end

    function save(file::File{format"DUMMY"}, data; extra=UInt8[])
        open(file, "w") do s
            save(s, data; extra=extra)
        end
    end

    function save(s::Stream{format"DUMMY"}, data; extra=UInt8[])
        write(s, magic(format"DUMMY"))  # Write the magic bytes
        write(s, convert(Int64, length(data)))
        udata = convert(Vector{UInt8}, data)
        write(s, udata)
        write(s, extra)
    end

    add_loader(format"DUMMY", Dummy)
    add_saver(format"DUMMY", Dummy)

end # module Dummy

@testset "Save" begin
    a = [0x01,0x02,0x03]
    fn = string(tempname(), ".dmy")
    save(fn, a)
    @test metadata(fn) == 3

    # Test for absolute paths
    cd(dirname(fn)) do
        fnrel = basename(fn)
        f = query(fnrel)
        @test isabspath(filename(f))
        @test endswith(filename(f),fn) # TravisOSX prepends "/private"
        f = File{format"DUMMY"}(fnrel)
        @test !(isabspath(filename(f)))
        open(f) do s
            @test isabspath(filename(s))
            @test endswith(filename(s), fn)
        end
    end

    fn2 = string(tempname(), ".dmy")
    a |> save(fn2)

    # Test for absolute paths
    cd(dirname(fn2)) do
        fnrel = basename(fn2)
        f = query(fnrel)
        @test isabspath(filename(f))
        @test endswith(filename(f),fn2) # TravisOSX prepends "/private"
        f = File{format"DUMMY"}(fnrel)
        @test !(isabspath(filename(f)))
        open(f) do s
            @test isabspath(filename(s))
            @test endswith(filename(s),fn2)
        end
    end
    rm(fn2)

    # Test IO
    b = load(query(fn))
    @test a == b

    b = open(query(fn)) do s
        load(s)
    end
    @test a == b

    # low-level I/O test
    open(query(fn)) do s
        @test position(s) == 0
        skipmagic(s)
        @test position(s) == length(magic(format"DUMMY"))
        seek(s, 1)
        @test position(s) == 1
        seekstart(s)
        @test position(s) == 0
        seekend(s)
        @test eof(s)
        skip(s, -position(s)+1)
        @test position(s) == 1
        @test isreadonly(s)
        @test isopen(s)
        @test read(s,2) == b"UM"
    end
    rm(fn)

    # streaming I/O with filenames
    fn = string(tempname(), ".dmy")
    save(fn, a)
    loadstreaming(fn) do reader
        @test read(reader) == a
    end
    rm(fn)
    savestreaming(fn) do writer
        write(writer, a)
    end
    @test load(fn) == a
    rm(fn)

    if Threads.nthreads() > 1
        Threads.@threads for i in 1:(Threads.nthreads() * 5)
            fn = string(tempname(), ".dmy")
            save(fn, a)
        end
    end

    # force format
    fn = string(tempname(), ".dmy")
    savestreaming(format"DUMMY", fn) do writer
        write(writer, a)
    end
    @test load(fn) == a
    rm(fn)

    # streaming I/O with streams
    save(fn, a)
    open(fn) do io
        loadstreaming(io) do reader
            @test read(reader) == a
        end
        @test isopen(io)
    end
    rm(fn)
    open(fn, "w") do io
        savestreaming(format"DUMMY", io) do writer
            write(writer, a)
        end
        @test isopen(io)
    end
    @test load(fn) == a
    rm(fn)

    # test keyword arguments

    a = [0x01,0x02,0x03]
    fn = string(tempname(), ".dmy")
    save(fn, a; extra=[0x42, 0x43])
    # the loader verifies that the extra data was written properly
    load(fn; extra=[0x42, 0x43])

    @test_throws Exception save("missing.fmt",5)
end

@testset "Overwrite file with bad magic bytes" begin
    # issue #267
    a = [0x01,0x02,0x03]
    fn = tempname()*".dmy"
    open(fn, "w") do io
        write(io, "Ceci n'est pas un DUMMY")
    end
    save(fn, a)
    @test isa(query(fn), File{format"DUMMY"})
    @test load(fn) == a
    rm(fn)
end

del_format(format"DUMMY")

# PPM/PBM can be either binary or text. Test that the defaults work,
# and that we can force a choice.
module AmbigExt
    using FileIO: File, @format_str, Stream, stream, skipmagic

    load(f::File{format"AmbigExt1"}) = open(f) do io
        skipmagic(io)
        read(stream(io), String)
    end
    load(f::File{format"AmbigExt2"}) = open(f) do io
        skipmagic(io)
        read(stream(io), String)
    end

    fileio_save(f::File{format"AmbigExt1"}, testdata) = open(f, "w") do io
        s = stream(io)
        print(s, "ambigext1")
        print(s, testdata)
    end
    fileio_save(f::File{format"AmbigExt2"}, testdata) = open(f, "w") do io
        s = stream(io)
        print(s, "ambigext2")
        print(s, testdata)
    end
end

@testset "Ambiguous extension" begin
    add_format(format"AmbigExt1", "ambigext1", ".aext", [AmbigExt])
    add_format(format"AmbigExt2", "ambigext2", ".aext", [AmbigExt])
    A = "this is a test"
    fn = string(tempname(), ".aext")
    # Test the forced version first: we wouldn't want some method in Netpbm
    # coming to the rescue here, we want to rely on FileIO's logic.
    # `save(fn, A)` will load Netpbm, which could conceivably mask a failure
    # in the next line.
    save(format"AmbigExt2", fn, A)

    B = load(fn)
    @test B == A
    @test typeof(query(fn)) <: File{format"AmbigExt2"}
    rm(fn)

    save(fn, A)
    B = load(fn)
    @test B == A
    @test typeof(query(fn)) <: File{format"AmbigExt1"}

    rm(fn)
    del_format(format"AmbigExt1")
    del_format(format"AmbigExt2")
end

@testset "Absent file" begin
    @test_throws Union{ArgumentError,SystemError} load("nonexistent.oops")
end

module BadOverride
    using FileIO
    FileIO.load(::File{format"OVERRIDE"}) = 22
    add_format(format"OVERRIDE", "OVRD0101", ".ovr", [BadOverride])
end

@testset "Warn FileIO overrides" begin
    fn = string(tempname(), ".ovr")
    open(fn, "w") do io
        write(io, magic(:OVERRIDE))
        print(io, "\nDone")
    end
    @test (@test_logs (:warn, r"incorrectly extends FileIO functions \(see FileIO documentation\)") load(fn)) == 22
end

# Julia 1.0 in Windows (Github Action) is problematic when downloading the file so we skip it
if VERSION >= v"1.3" begin
    @testset "CSV load from URL via CSVFiles (#320)" begin
        f = joinpath("files", "data.csv")
        c1 = load(f)
        c2 = load("https://raw.githubusercontent.com/queryverse/CSVFiles.jl/v0.2.0/test/data.csv")
        @test collect(c1) == collect(c2)
    end
end

end
