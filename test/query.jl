using FileIO
using Test
using Random

@testset "OS" begin
    if Sys.islinux()
        @test FileIO.applies_to_os(FileIO.Linux)
        @test !(FileIO.applies_to_os(FileIO.OSX))
        @test FileIO.applies_to_os(FileIO.Unix)
        @test !(FileIO.applies_to_os(FileIO.Windows))
    end
    if Sys.isapple()
        @test !(FileIO.applies_to_os(FileIO.Linux))
        @test FileIO.applies_to_os(FileIO.OSX)
        @test FileIO.applies_to_os(FileIO.Unix)
        @test !(FileIO.applies_to_os(FileIO.Windows))
    end
    if Sys.iswindows()
        @test !(FileIO.applies_to_os(FileIO.Linux))
        @test !(FileIO.applies_to_os(FileIO.OSX))
        @test !(FileIO.applies_to_os(FileIO.Unix))
        @test FileIO.applies_to_os(FileIO.Windows)
    end
end

# Before we bork things, make a copy
ext2sym = copy(FileIO.ext2sym)
magic_list = copy(FileIO.magic_list)
sym2info = copy(FileIO.sym2info)


module LoadTest1
import FileIO: @format_str, File
load(file::File{format"MultiLib"}) = error()

save(file::File{format"MultiLib"}, data) = open(file, "w") do s
    write(s, magic(format"MultiLib"))  # Write the magic bytes
    write(s, 0)
end

end
module LoadTest2
import FileIO: @format_str, File, magic
load(file::File{format"MultiLib"}) = 42

save(file::File{format"MultiLib"}, data) = open(file, "w") do s
    write(s, magic(format"MultiLib"))  # Write the magic bytes
    write(s, 42)
end

end

# this does not like to live in the try block
add_format(format"JUNK", "JUNK", [".jnk",".junk",".JNK"])
@test_throws Exception add_format(format"JUNK2","JUNK",".jnk2") # magic bytes already registered
del_format(format"JUNK")  # This triggers del_extension for multiple extensions


try
    empty!(FileIO.ext2sym)
    empty!(FileIO.magic_list)
    empty!(FileIO.sym2info)

    @testset "DataFormat" begin
        @test DataFormat{:CSV} == format"CSV"
        @test !(unknown(format"CSV"))
        @test unknown(format"UNKNOWN")

        add_format(format"CSV", UInt8[], ".csv")
        @test FileIO.info(format"CSV") == ((),".csv")
        add_format(format"FOO", (), ".foo")  # issue #17
        @test_throws Exception FileIO.info(format"OOPS")
        @test FileIO.ext2sym[".csv"] == :CSV
        del_format(format"FOO")
        @test FileIO.magic_list == [Pair((),:CSV)]
        del_format(format"CSV")
        @test isempty(FileIO.ext2sym)
        @test isempty(FileIO.magic_list)
        @test isempty(FileIO.sym2info)
        @test_throws Exception FileIO.info(format"CSV")

        add_format(format"JUNK", "JUNK", [".jnk",".junk",".JNK"])

        @test FileIO.info(format"JUNK") == (tuple(b"JUNK"...),[".jnk",".junk",".JNK"])
        @test FileIO.ext2sym[".jnk"] == :JUNK
        @test FileIO.ext2sym[".junk"] == :JUNK
        @test FileIO.ext2sym[".JNK"] == :JUNK
        @test FileIO.magic_list == [Pair((0x4a,0x55,0x4e,0x4b),:JUNK)]

    end

    @testset "streams" begin
        io = IOBuffer()
        s = Stream(format"JUNK", io)
        @test typeof(s) == Stream{DataFormat{:JUNK},IOBuffer}
        @test filename(s) == nothing
        @test_throws Exception FileIO.file!(s)
        s = Stream(format"JUNK", io, "junk.jnk")
        @test filename(s) == "junk.jnk"
        s = Stream(format"JUNK", io, "junk2.jnk")
        @test filename(s) == "junk2.jnk"
    end

    @testset "query" begin
        # Streams
        io = IOBuffer()
        write(io, "Weird format")
        seek(io, 0)
        q = query(io)
        @test unknown(q)

        # Short "file"
        truncate(io, 0)
        write(io, "S")
        seek(io, 0)
        q = query(io)
        @test unknown(q)

        truncate(io, 0)
        write(io, "JUNK and some more stuff")
        seek(io, 0)
        q = query(io)
        @test typeof(q) == Stream{format"JUNK",typeof(io)}
        @test !(unknown(q))
        @test file_extension(q) == nothing

        # File with correct extension
        str = String(take!(io))
        fn = string(tempname(), ".jnk")
        open(fn, "w") do file
            write(file, str)
        end
        q = query(fn)
        @test typeof(q) == File{format"JUNK"}
        @test file_extension(q) == ".jnk"

        rm(fn)

        # File with erroneous extension
        fn = string(tempname(), ".csv")
        open(fn, "w") do file
            write(file, str)
        end
        q = query(fn)
        @test typeof(q) == File{format"JUNK"}
        @test file_extension(q) == ".csv"
        rm(fn)

        # Format with no magic bytes
        add_format(format"BAD", (), ".bad")
        fn = string(tempname(), ".bad")
        open(fn, "w") do file
            write(file, "Here's some data")
        end
        q = query(fn)
        @test typeof(q) == File{format"BAD"}
        @test file_extension(q) == ".bad"
        rm(fn)

        q = query( "some_non_existant_file.bad")
        @test typeof(q) == File{format"BAD"}

        # Unknown extension
        fn = string("tempname", ".wrd")
        open(fn, "w") do file
            write(file, "More data")
        end
        @test unknown(query(fn))
        rm(fn)

        add_format(format"DOUBLE_1", "test1", ".double")
        add_format(format"DOUBLE_2", "test2", ".double")

        fn = string(tempname(), ".double")
        open(fn, "w") do file
            write(file, "test1")
        end
        q = query(fn)
        @test typeof(q) == File{format"DOUBLE_1"}
        rm(fn)


        add_format(format"MAGIC", "this so magic", ".mmm")
        q = query( "some_non_existant_file.mmm")
        @test typeof(q) == File{format"MAGIC"}

        add_format(format"DOUBLE_MAGIC", (UInt8[0x4d,0x4d,0x00,0x2a], UInt8[0x4d,0x4d,0x00]), ".dd2")

        fn = string(tempname(), ".dd2")
        open(fn, "w") do file
            write(file, UInt8[0x4d,0x4d,0x00,0x2a])
            write(file, randstring(19))
        end
        q = query(fn)
        @test typeof(q) == File{format"DOUBLE_MAGIC"}
        io = open(q)
        skipmagic(io)
        @test position(io) == 4
        close(io)
        rm(fn)

        open(fn, "w") do file
            write(file, UInt8[0x4d,0x4d,0x00])
            write(file, randstring(19))
        end
        q = query(fn)
        @test typeof(q) == File{format"DOUBLE_MAGIC"}
        io = open(q)
        @test file_extension(q) == ".dd2"
        skipmagic(io)
        @test position(io) == 3
        close(io)
        open(fn, "w") do file
            write(file, randstring(19)) # corrupt magic bytes
        end
        open(fn, "r") do file
            @test_throws Exception skipmagic(file)
        end
        rm(fn)
        lene0 = length(FileIO.ext2sym)
        lenm0 = length(FileIO.magic_list)
        del_format(format"DOUBLE_MAGIC")
        @test lene0 - 1 == length(FileIO.ext2sym)
        @test lenm0 - 2 == length(FileIO.magic_list)
    end

    del_format(format"JUNK")  # This triggers del_extension for multiple extensions


    @testset "multiple libs" begin
        lensave0 = length(FileIO.sym2saver)
        lenload0 = length(FileIO.sym2loader)
        OSKey = Sys.isapple() ? FileIO.OSX : Sys.iswindows() ? FileIO.Windows : Sys.islinux() ? FileIO.Linux : error("os not supported")
        add_format(
            format"MultiLib",
            UInt8[0x42,0x4d],
            ".mlb",
            [:LoadTest1, FileIO.LOAD, OSKey],
            [:LoadTest2]
        )
        @test lensave0 + 1 == length(FileIO.sym2saver)
        @test lenload0 + 1 == length(FileIO.sym2loader)
        @test length(FileIO.sym2loader[:MultiLib]) == 2
        @test length(FileIO.sym2saver[:MultiLib]) == 1
        fn = string(tempname(), ".mlb")
        save(fn, nothing)
        x = load(fn)
        open(query(fn), "r") do io
            skipmagic(io)
            a = read(io, Int)
            @test a == 42 #make sure that LoadTest2 is used for saving, even though its at position 2
        end
        @test isdefined(Main, :LoadTest1) # first module should load first but fail
        @test x == 42
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
@testset "bedGraph" begin
    q = query(joinpath(file_dir, "file.bedgraph"))
    @test typeof(q) == File{format"bedGraph"}
    open(q) do io
        @test position(io) == 0
        skipmagic(io)
        @test position(io) == 0 # no skipping for functions
        # @test FileIO.detect_bedgraph(io) # MethodError: no method matching readline(::FileIO.Stream{FileIO.DataFormat{:bedGraph},IOStream}; chomp=false)
    end
    open(joinpath(file_dir, "file.bedgraph")) do io
        @test (FileIO.detect_bedgraph(io))
    end
end
@testset "STL detection" begin
    q = query(joinpath(file_dir, "ascii.stl"))
    @test typeof(q) == File{format"STL_ASCII"}
    q = query(joinpath(file_dir, "binary_stl_from_solidworks.STL"))
    @test typeof(q) == File{format"STL_BINARY"}
    open(q) do io
        @test position(io) == 0
        skipmagic(io)
        @test position(io) == 0 # no skipping for functions
    end
end
@testset "PLY detection" begin
    q = query(joinpath(file_dir, "ascii.ply"))
    @test typeof(q) == File{format"PLY_ASCII"}
    q = query(joinpath(file_dir, "binary.ply"))
    @test typeof(q) == File{format"PLY_BINARY"}

end
@testset "Multiple Magic bytes" begin
    q = query(joinpath(file_dir, "magic1.tiff"))
    @test typeof(q) == File{format"TIFF"}
    q = query(joinpath(file_dir, "magic2.tiff"))
    @test typeof(q) == File{format"TIFF"}
    open(q) do io
        @test position(io) == 0
        skipmagic(io)
        @test position(io) == 4
    end
end
@testset "AVI Detection" begin
    open(joinpath(file_dir, "bees.avi")) do s
        @test FileIO.detectavi(s)
    end
    open(joinpath(file_dir, "sin.wav")) do s
        @test !(FileIO.detectavi(s))
    end
    open(joinpath(file_dir, "magic1.tiff")) do s
        @test !(FileIO.detectavi(s))
    end
    q = query(joinpath(file_dir, "bees.avi"))
    @test typeof(q) == File{format"AVI"}
end
@testset "RDA detection" begin
    q = query(joinpath(file_dir, "minimal_ascii.rda"))
    @test typeof(q) == File{format"RData"}
    open(q) do io
        @test position(io) == 0
        @test FileIO.detect_rdata(io)
        # 6 for /r/n  and 5 for /n
        @test (position(io) in (5, 6))
    end
end
@testset "RDS detection" begin
    q = query(joinpath(file_dir, "minimal_ascii.rds"))
    @test typeof(q) == File{format"RDataSingle"}
    open(q) do io
        @test position(io) == 0
        @test FileIO.detect_rdata_single(io)
        # need to seek to beginning of file where data structure starts
        @test position(io)  == 0
    end
end
@testset "Format with function for magic bytes" begin
    add_format(format"FUNCTION_FOR_MAGIC_BYTES", x -> 0x00, ".wav", [:WAV])
    del_format(format"FUNCTION_FOR_MAGIC_BYTES")
end
