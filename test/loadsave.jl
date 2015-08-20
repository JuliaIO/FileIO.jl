using FileIO, Compat
using FactCheck

# Stub readers---these might bork any existing readers, so don't
# run these tests while doing other things!
FileIO.load(file::File{format"PBMText"})   = "PBMText"
FileIO.load(file::File{format"PBMBinary"}) = "PBMBinary"
FileIO.load(file::File{format"HDF5"})      = "HDF5"
FileIO.load(file::File{format"JLD"})       = "JLD"

sym2loader = copy(FileIO.sym2loader)
sym2saver = copy(FileIO.sym2saver)

try
    empty!(FileIO.sym2loader)
    empty!(FileIO.sym2saver)

    facts("Load") do
        @fact load(joinpath("files", "file1.pbm")) --> "PBMText"
        @fact load(joinpath("files", "file2.pbm")) --> "PBMBinary"
        # Regular HDF5 file with magic bytes starting at position 0
        @fact load(joinpath("files", "file1.h5")) --> "HDF5"
        # This one is actually a JLD file saved with an .h5 extension,
        # and the JLD magic bytes edited to prevent it from being recognized
        # as JLD.
        # JLD files are also HDF5 files, so this should be recognized as
        # HDF5. However, what makes this more interesting is that the
        # magic bytes start at position 512.
        @fact load(joinpath("files", "file2.h5")) --> "HDF5"
        # JLD file saved with .jld extension
        @fact load(joinpath("files", "file.jld")) --> "JLD"

        @fact_throws load("missing.fmt")
    end
finally
    merge!(FileIO.sym2loader, sym2loader)
    merge!(FileIO.sym2saver, sym2saver)
end

# A tiny but complete example
# DUMMY format is:
#  - n, a single Int64
#  - a vector of length n of UInt8s

add_format(format"DUMMY", b"DUMMY", ".dmy")

module Dummy

using FileIO, Compat

function FileIO.load(file::File{format"DUMMY"})
    s = open(file)
    skipmagic(s)
    load(s)
end

function FileIO.load(s::Stream{format"DUMMY"})
    # We're already past the magic bytes
    n = read(s, Int64)
    out = Array(UInt8, n)
    read!(s, out)
    close(s)
    out
end

function FileIO.save(file::File{format"DUMMY"}, data)
    open(file, "w") do io
        write(io, magic(format"DUMMY"))  # Write the magic bytes
        write(io, convert(Int64, length(data)))
        udata = convert(Vector{UInt8}, data)
        write(io, udata)
    end
end

end

add_loader(format"DUMMY", :Dummy)
add_saver(format"DUMMY", :Dummy)

facts("Save") do
    a = [0x01,0x02,0x03]
    fn = string(tempname(), ".dmy")
    save(fn, a)

    b = load(query(fn))
    @fact a --> b

    b = open(query(fn)) do s
        skipmagic(s)
        load(s)
    end
    @fact a --> b

    # low-level I/O test
    open(query(fn)) do s
        @fact position(s) --> 0
        skipmagic(s)
        @fact position(s) --> length(magic(format"DUMMY"))
        seek(s, 1)
        @fact position(s) --> 1
        seekstart(s)
        @fact position(s) --> 0
        seekend(s)
        @fact eof(s) --> true
        skip(s, -position(s)+1)
        @fact position(s) --> 1
        @fact isreadonly(s) --> true
        @fact isopen(s) --> true
        @fact readbytes(s, 2) --> b"UM"
    end
    rm(fn)

    @fact_throws save("missing.fmt", 5)
end

del_format(format"DUMMY")
