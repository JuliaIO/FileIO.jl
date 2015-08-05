using FileIO
using FactCheck

if VERSION < v"0.4.0-dev"
    using Compat
    import FileIO.Pair
end

# Before we bork things, make a copy
ext2sym = copy(FileIO.ext2sym)
magic_list = copy(FileIO.magic_list)
sym2info = copy(FileIO.sym2info)

try
    empty!(FileIO.ext2sym)
    empty!(FileIO.magic_list)
    empty!(FileIO.sym2info)

    facts("DataFormat") do
        @fact DataFormat{:CSV} --> format"CSV"
        @fact unknown(format"CSV") --> false
        @fact unknown(format"UNKNOWN") --> true

        add_format(format"CSV", UInt8[], ".csv")
        @fact info(format"CSV") --> ((), ".csv")
        add_format(format"FOO", (), ".foo")  # issue #17
        @fact_throws info(format"OOPS")
        @fact FileIO.ext2sym[".csv"] --> :CSV
        del_format(format"FOO")
        @fact FileIO.magic_list --> [Pair((), :CSV)]
        del_format(format"CSV")
        @fact isempty(FileIO.ext2sym) --> true
        @fact isempty(FileIO.magic_list) --> true
        @fact isempty(FileIO.sym2info) --> true
        @fact_throws info(format"CSV")

        add_format(format"JUNK", "JUNK", [".jnk",".junk"])
        @fact info(format"JUNK") --> (tuple(b"JUNK"...), [".jnk",".junk"])
        @fact FileIO.ext2sym[".jnk"]  --> :JUNK
        @fact FileIO.ext2sym[".junk"] --> :JUNK
        @fact FileIO.magic_list --> [Pair((0x4a,0x55,0x4e,0x4b),:JUNK)]
    end

    facts("query") do
        # Streams
        io = IOBuffer()
        write(io, "Weird format")
        seek(io, 0)
        q = query(io)
        @fact unknown(q) --> true

        truncate(io, 0)
        write(io, "JUNK and some more stuff")
        seek(io, 0)
        q = query(io)
        @fact typeof(q) --> Stream{format"JUNK",typeof(io)}
        @fact unknown(q) --> false

        # File with correct extension
        str = takebuf_string(io)
        fn = string(tempname(), ".jnk")
        open(fn, "w") do file
            write(file, str)
        end
        q = query(fn)
        @fact typeof(q) --> File{format"JUNK"}
        rm(fn)

        # File with erroneous extension
        fn = string(tempname(), ".csv")
        open(fn, "w") do file
            write(file, str)
        end
        q = query(fn)
        @fact typeof(q) --> File{format"JUNK"}
        rm(fn)

        # Format with no magic bytes
        add_format(format"BAD", (), ".bad")
        fn = string(tempname(), ".bad")
        open(fn, "w") do file
            write(file, "Here's some data")
        end
        q = query(fn)
        @fact typeof(q) --> File{format"BAD"}
        rm(fn)

        # Unknown extension
        fn = string("tempname", ".wrd")
        open(fn, "w") do file
            write(file, "More data")
        end
        @fact unknown(query(fn)) --> true
        rm(fn)
    end
finally
    empty!(FileIO.ext2sym)
    empty!(FileIO.magic_list)
    empty!(FileIO.sym2info)

    merge!(FileIO.ext2sym, ext2sym)
    append!(FileIO.magic_list, magic_list)
    merge!(FileIO.sym2info, sym2info)
end
