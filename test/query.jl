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


module LoadTest1
import FileIO: @format_str, File
load(file::File{format"MultiLib"}) = error()

save(file::File{format"MultiLib"}) = open(file, "w") do s
    write(s, magic(format"MultiLib"))  # Write the magic bytes
    write(s, 0)
end

end
module LoadTest2
import FileIO: @format_str, File, magic
load(file::File{format"MultiLib"}) = 42

save(file::File{format"MultiLib"}) = open(file, "w") do s
    write(s, magic(format"MultiLib"))  # Write the magic bytes
    write(s, 42)
end

end

try
    empty!(FileIO.ext2sym)
    empty!(FileIO.magic_list)
    empty!(FileIO.sym2info)

    context("DataFormat") do
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

    context("streams") do
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

    context("query") do
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

        add_format(format"DOUBLE_MAGIC", (UInt8[0x4d,0x4d,0x00,0x2a], UInt8[0x4d,0x4d,0x00]), ".dd2")

        fn = string(tempname(), ".dd2")
        open(fn, "w") do file
            write(file, UInt8[0x4d,0x4d,0x00,0x2a])
            write(file, randstring(19))
        end
        q = query(fn)
        @fact typeof(q) --> File{format"DOUBLE_MAGIC"}
        io = open(q)
        skipmagic(io)
        @fact position(io) --> 4
        close(io)
        rm(fn)

        open(fn, "w") do file
            write(file, UInt8[0x4d,0x4d,0x00])
            write(file, randstring(19))
        end
        q = query(fn)
        @fact typeof(q) --> File{format"DOUBLE_MAGIC"}
        io = open(q)
        @fact file_extension(q) --> ".dd2"
        skipmagic(io)
        @fact position(io) --> 3
        close(io)
        open(fn, "w") do file
            write(file, randstring(19)) # corrupt magic bytes
        end
        open(fn, "r") do file
            @fact_throws skipmagic(file)
        end
        rm(fn)
        lene0 = length(FileIO.ext2sym)
        lenm0 = length(FileIO.magic_list)
        del_format(format"DOUBLE_MAGIC")
        @fact lene0 - 1 --> length(FileIO.ext2sym)
        @fact lenm0 - 2 --> length(FileIO.magic_list)
    end

    del_format(format"JUNK")  # This triggers del_extension for multiple extensions

    context("multiple libs") do
        lensave0 = length(FileIO.sym2saver)
        lenload0 = length(FileIO.sym2loader)
        OSKey = @osx ? FileIO.OSX : @windows? FileIO.Windows : @linux ? FileIO.Linux : error("os not supported")
        add_format(
            format"MultiLib", 
            UInt8[0x42,0x4d],
            ".mlb",
            [:LoadTest1, FileIO.LOAD, OSKey], 
            [:LoadTest2]
        )
        @fact lensave0 + 1 --> length(FileIO.sym2saver)
        @fact lenload0 + 1 --> length(FileIO.sym2loader)
        @fact length(FileIO.sym2loader[:MultiLib]) --> 2
        @fact length(FileIO.sym2saver[:MultiLib]) --> 1
        fn = string(tempname(), ".mlb")
        save(fn)
        x = load(fn)
        open(query(fn), "r") do io
            skipmagic(io)
            a = read(io, Int)
            @fact a --> 42 #make sure that LoadTest2 is used for saving, even though its at position 2
        end
        @fact isdefined(:LoadTest1) --> true # first module should load first but fail
        @fact x --> 42
        rm(fn)
    end
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
context("STL detection") do 
    q = query(joinpath(file_dir, "ascii.stl"))
    @fact typeof(q) --> File{format"STL_ASCII"}
    q = query(joinpath(file_dir, "binary_stl_from_solidworks.STL"))
    @fact typeof(q) --> File{format"STL_BINARY"}
    open(q) do io 
        @fact position(io) --> 0
        skipmagic(io)
        @fact position(io) --> 0 # no skipping for functions
    end
end
context("PLY detection") do 
    q = query(joinpath(file_dir, "ascii.ply"))
    @fact typeof(q) --> File{format"PLY_ASCII"}
    q = query(joinpath(file_dir, "binary.ply"))
    @fact typeof(q) --> File{format"PLY_BINARY"}

end
context("Multiple Magic bytes") do 
    q = query(joinpath(file_dir, "magic1.tiff"))
    @fact typeof(q) --> File{format"TIFF"}
    q = query(joinpath(file_dir, "magic2.tiff"))
    @fact typeof(q) --> File{format"TIFF"}
    open(q) do io
        @fact position(io) --> 0
        skipmagic(io)
        @fact position(io) --> 4
    end
end