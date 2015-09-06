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

        add_format(format"JUNK", "JUNK", [".jnk",".junk",".JNK"])
        @fact info(format"JUNK") --> (tuple(b"JUNK"...), [".jnk",".junk",".JNK"])
        @fact FileIO.ext2sym[".jnk"]  --> :JUNK
        @fact FileIO.ext2sym[".junk"] --> :JUNK
        @fact FileIO.ext2sym[".JNK"]  --> :JUNK
        @fact FileIO.magic_list --> [Pair((0x4a,0x55,0x4e,0x4b),:JUNK)]
        @fact_throws add_format(format"JUNK2", "JUNK", ".jnk2")  # magic bytes already registered

    end

    facts("streams") do
        io = IOBuffer()
        s = Stream(format"JUNK", io)
        @fact typeof(s) --> Stream{DataFormat{:JUNK}, IOBuffer}
        @fact isnull(filename(s)) --> true
        @fact_throws FileIO.file!(s)
        s = Stream(format"JUNK", io, "junk.jnk")
        @fact get(filename(s)) --> "junk.jnk"
        s = Stream(format"JUNK", io, Nullable("junk2.jnk"))
        @fact get(filename(s)) --> "junk2.jnk"
    end

    facts("query") do
        # Streams
        io = IOBuffer()
        write(io, "Weird format")
        seek(io, 0)
        q = query(io)
        @fact unknown(q) --> true

        # Short "file"
        truncate(io, 0)
        write(io, "S")
        seek(io, 0)
        q = query(io)
        @fact unknown(q) --> true

        truncate(io, 0)
        write(io, "JUNK and some more stuff")
        seek(io, 0)
        q = query(io)
        @fact typeof(q) --> Stream{format"JUNK",typeof(io)}
        @fact unknown(q) --> false
        @fact isnull(file_extension(q)) --> true

        # File with correct extension
        str = takebuf_string(io)
        fn = string(tempname(), ".jnk")
        open(fn, "w") do file
            write(file, str)
        end
        q = query(fn)
        @fact typeof(q) --> File{format"JUNK"}
        @fact file_extension(q) --> ".jnk"

        rm(fn)

        # File with erroneous extension
        fn = string(tempname(), ".csv")
        open(fn, "w") do file
            write(file, str)
        end
        q = query(fn)
        @fact typeof(q) --> File{format"JUNK"}
        @fact file_extension(q) --> ".csv"
        rm(fn)

        # Format with no magic bytes
        add_format(format"BAD", (), ".bad")
        fn = string(tempname(), ".bad")
        open(fn, "w") do file
            write(file, "Here's some data")
        end
        q = query(fn)
        @fact typeof(q) --> File{format"BAD"}
        @fact file_extension(q) --> ".bad"
        rm(fn)

        q = query( "some_non_existant_file.bad")
        @fact typeof(q) --> File{format"BAD"}

        # Unknown extension
        fn = string("tempname", ".wrd")
        open(fn, "w") do file
            write(file, "More data")
        end
        @fact unknown(query(fn)) --> true
        rm(fn)

        add_format(format"DOUBLE_1", "test1", ".double")
        add_format(format"DOUBLE_2", "test2", ".double")

        @fact_throws ErrorException query( "test.double")
        fn = string(tempname(), ".double")
        open(fn, "w") do file
            write(file, "test1")
        end
        q = query(fn)
        @fact typeof(q) --> File{format"DOUBLE_1"}
        rm(fn)


        add_format(format"MAGIC", "this so magic", ".mmm")
        q = query( "some_non_existant_file.mmm")
        @fact typeof(q) --> File{format"MAGIC"}

    end

    del_format(format"JUNK")  # This triggers del_extension for multiple extensions

finally
    # Restore the registry
    empty!(FileIO.ext2sym)
    empty!(FileIO.magic_list)
    empty!(FileIO.sym2info)

    merge!(FileIO.ext2sym, ext2sym)
    append!(FileIO.magic_list, magic_list)
    merge!(FileIO.sym2info, sym2info)
end

file_dir = joinpath(dirname(@__FILE__), "files")
facts("STL detection") do 
    q = query(joinpath(file_dir, "ascii.stl"))
    @fact typeof(q) --> File{format"STL_ASCII"}
    q = query(joinpath(file_dir, "binary_stl_from_solidworks.STL"))
    @fact typeof(q) --> File{format"STL_BINARY"}
end

facts("PLY detection") do 
    q = query(joinpath(file_dir, "ascii.ply"))
    @fact typeof(q) --> File{format"PLY_ASCII"}
    q = query(joinpath(file_dir, "binary.ply"))
    @fact typeof(q) --> File{format"PLY_BINARY"}
end
