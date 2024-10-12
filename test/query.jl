using FileIO
using Test
using Random
import Downloads

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

@testset "Double register" begin
    add_format(format"JUNK", "JUNK", [".jnk",".junk",".JNK"])
    @test_throws Exception add_format(format"JUNK2","JUNK",".jnk2") # magic bytes already registered
    del_format(format"JUNK")  # This triggers del_extension for multiple extensions
end

@testset "Format with function for magic bytes" begin
    add_format(format"FUNCTION_FOR_MAGIC_BYTES", io -> true, ".wav", [LoadTest1])
    del_format(format"FUNCTION_FOR_MAGIC_BYTES")
end

@testset "Fake registry" begin
    # Before we bork things, make a copy
    ext2sym = copy(FileIO.ext2sym)
    magic_list = copy(FileIO.magic_list)
    sym2info = copy(FileIO.sym2info)

    try
        empty!(FileIO.ext2sym)
        empty!(FileIO.magic_list)
        empty!(FileIO.sym2info)

        @testset "DataFormat" begin
            @test DataFormat{:CSV} == format"CSV"
            @test !(unknown(format"CSV"))
            @test unknown(format"UNKNOWN")

            add_format(format"CSV", UInt8[], ".csv")
            @test FileIO.info(format"CSV") == ([],".csv")
            add_format(format"FOO", (), ".foo")  # issue #17
            @test_throws Exception FileIO.info(format"OOPS")
            @test FileIO.ext2sym[".csv"] == :CSV
            del_format(format"FOO")
            @test FileIO.magic_list == [Pair([],:CSV)]
            del_format(format"CSV")
            @test isempty(FileIO.ext2sym)
            @test isempty(FileIO.magic_list)
            @test isempty(FileIO.sym2info)
            @test_throws Exception FileIO.info(format"CSV")

            add_format(format"JUNK", "JUNK", [".jnk",".junk",".JNK"])

            @test FileIO.info(format"JUNK") == (b"JUNK",[".jnk",".junk",".JNK"])
            @test FileIO.ext2sym[".jnk"] == :JUNK
            @test FileIO.ext2sym[".junk"] == :JUNK
            @test FileIO.ext2sym[".JNK"] == :JUNK
            @test FileIO.magic_list == [Pair([0x4a,0x55,0x4e,0x4b],:JUNK)]

            add_format(format"OTHER", [0x01, 0x02], ".othr")
        end

        @testset "streams" begin
            io = IOBuffer()
            s = Stream{format"JUNK"}(io)
            @test typeof(s) <: Stream{DataFormat{:JUNK},IOBuffer}
            @test filename(s) == nothing
            @test_throws ErrorException("filename unknown") FileIO.file!(s)
            s = Stream{format"JUNK"}(io, "junk.jnk")
            @test filename(s) == "junk.jnk"
            s = Stream{format"JUNK"}(io, "junk2.jnk")
            @test filename(s) == "junk2.jnk"
            s = Stream{format"JUNK"}(io, "somefile.jnk")
            @test FileIO.file!(s) isa File{format"JUNK"}
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
            @test typeof(q) <: Stream{format"JUNK",typeof(io)}
            @test !(unknown(q))
            @test file_extension(q) == nothing
            # unseekable IO
            seek(io, 0)
            io.seekable = false
            @test !FileIO.seekable(io)
            q = query(io)
            @test typeof(q) <: Stream{format"JUNK",typeof(io)}
            io.seekable = true
            # too short to match
            io2 = IOBuffer()
            write(io2, "JU")
            seek(io2, 0)
            io2.seekable = false
            q = query(io2)
            @test unknown(q)

            # File with correct extension
            str = String(take!(io))
            fn = string(tempname(), ".jnk")
            open(fn, "w") do file
                write(file, str)
            end
            q = query(fn)
            @test typeof(q) <: File{format"JUNK"}
            @test file_extension(q) == ".jnk"
            # for good measure, test some constructors & other query calls
            @test query(q) == q
            @test File{format"JUNK"}(q) == q
            @test_throws ArgumentError("cannot change the format of $q to OTHER") File{format"OTHER"}(q)
            open(fn) do io
                @test query(io) isa Stream{format"JUNK", typeof(io)}
                @test query(io, q) isa Stream{format"JUNK", typeof(io)}
                @test Stream(q, io) isa Stream{format"JUNK", typeof(io)}
                @test Stream{format"JUNK"}(q, io) isa Stream{format"JUNK", typeof(io)}
                @test_throws ArgumentError Stream{format"OTHER"}(q, io)
            end

            rm(fn)

            # File with erroneous extension
            fn = string(tempname(), ".csv")
            open(fn, "w") do file
                write(file, str)
            end
            q = query(fn)
            @test typeof(q) <: File{format"JUNK"}
            @test file_extension(q) == ".csv"
            rm(fn)
            # erroneous extension with a file that has magic bytes
            fn = string(tempname(), ".othr")
            open(fn, "w") do file
                write(file, str)
            end
            q = query(fn)
            @test typeof(q) <: File{format"JUNK"}
            @test query(fn; checkfile=false) isa File{format"OTHER"}
            rm(fn)

            # Format with no magic bytes
            add_format(format"BAD", (), ".bad")
            fn = string(tempname(), ".bad")
            open(fn, "w") do file
                write(file, "Here's some data")
            end
            q = query(fn)
            @test typeof(q) <: File{format"BAD"}
            @test file_extension(q) == ".bad"
            rm(fn)

            q = query( "some_non_existant_file.bad")
            @test typeof(q) <: File{format"BAD"}

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
            @test typeof(q) <: File{format"DOUBLE_1"}
            rm(fn)

            # Busted detection function
            busted(io) = error("whoops")
            add_format(format"BUSTED", busted, ".bstd")
            fn = string(tempname(), ".bstd")
            open(fn, "w") do file
                write(file, "JUNK stuff")
            end
            @test (@test_logs (:error,r"There was an error in magic function .*busted") query(fn)) isa File{format"JUNK"}
            del_format(format"BUSTED")

            add_format(format"MAGIC", "this so magic", ".mmm")
            q = query( "some_non_existant_file.mmm")
            @test typeof(q) <: File{format"MAGIC"}

            add_format(format"DOUBLE_MAGIC", (UInt8[0x4d,0x4d,0x00,0x2a], UInt8[0x4d,0x4d,0x00]), ".dd2")

            fn = string(tempname(), ".dd2")
            open(fn, "w") do file
                write(file, UInt8[0x4d,0x4d,0x00,0x2a])
                write(file, randstring(19))
            end
            q = query(fn)
            @test typeof(q) <: File{format"DOUBLE_MAGIC"}
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
            @test typeof(q) <: File{format"DOUBLE_MAGIC"}
            io = open(q)
            @test file_extension(q) == ".dd2"
            skipmagic(io)
            @test position(io) == 3
            close(io)
            open(fn, "w") do file
                write(file, randstring(19)) # corrupt magic bytes
            end
            open(fn, "r") do file
                @test_throws ErrorException("tried to skip magic bytes of an IO that does not contain the magic bytes of the format. IO: $file") skipmagic(Stream{format"DOUBLE_MAGIC"}(file, fn))
            end
            open(fn, "r") do file
                @test_throws ErrorException("tried to skip magic bytes of an IO that does not contain the magic bytes of the format. IO: $file") skipmagic(file, format"DOUBLE_MAGIC")
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
                [LoadTest1, FileIO.LOAD, OSKey],
                [LoadTest2]
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
end

@testset "detect $(format !== nothing ? format : "no") compression" for (ext, format) in [(nothing, nothing), (".gz", "GZIP"), (".bz2", "BZIP2"),
                                                            (".lz4", "LZ4"), (".xz", "XZ")]
    fname = joinpath(@__DIR__, "files", "dummy.txt")
    if ext !== nothing
        fname *= ext
    end
    open(fname) do io
        @test FileIO.detect_compressor(io, formats=[format]) == format # test with specific format only
    end
    open(fname) do io
        @test FileIO.detect_compressor(io, formats=[]) === nothing # test with no formats
    end
    open(fname) do io
        @test FileIO.detect_compressor(io) == format # test with all formats
    end
    open(fname) do io
        @test FileIO.detect_compressed(io) == (format !== nothing)
    end
end

let file_dir = joinpath(@__DIR__, "files"), file_path = Path(file_dir)
    @testset "Querying with $(typeof(fp))" for fp in (file_dir, file_path)
        @testset "bedGraph" begin
            q = query(joinpath(file_dir, "file.bedgraph"))
            @test typeof(q) <: File{format"bedGraph"}
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
            @test typeof(q) <: File{format"STL_ASCII"}
            q = query(joinpath(file_dir, "binary_stl_from_solidworks.STL"))
            @test typeof(q) <: File{format"STL_BINARY"}
            # See Pull Request # 388
            q = query(joinpath(file_dir, "binary_stl_with_nonzero_attribute_byte_count.stl"))
            @test typeof(q) <: File{format"STL_BINARY"}
            open(q) do io
                @test position(io) == 0
                skipmagic(io)
                @test position(io) == 0 # no skipping for functions
            end
        end
        @testset "PLY detection" begin
            q = query(joinpath(file_dir, "ascii.ply"))
            @test typeof(q) <: File{format"PLY_ASCII"}
            q = query(joinpath(file_dir, "binary.ply"))
            @test typeof(q) <: File{format"PLY_BINARY"}

        end
        @testset "Multiple Magic bytes" begin
            q = query(joinpath(file_dir, "magic1.tiff"))
            @test typeof(q) <: File{format"TIFF"}
            q = query(joinpath(file_dir, "magic2.tiff"))
            @test typeof(q) <: File{format"TIFF"}
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
            @test typeof(q) <: File{format"AVI"}
        end
        @testset "MP4 detection" begin
            # archive.org is down
            # f = Downloads.download("https://archive.org/download/LadybirdOpeningWingsCCBYNatureClip/Ladybird%20opening%20wings%20CC-BY%20NatureClip.mp4")
            # q = query(f)
            # @test typeof(q) <: File{format"MP4"}
        end
        if Base.VERSION >= v"1.6" || !Sys.iswindows()
            # FIXME: Windows fails to download the files on Julia 1.0
            @testset "OGG detection" begin
                f = Downloads.download("https://upload.wikimedia.org/wikipedia/commons/8/87/Annie_Oakley_shooting_glass_balls%2C_1894.ogv")
                q = query(f)
                @test typeof(q) <: File{format"OGG"}
            end
            @testset "MATROSKA detection" begin
                f = Downloads.download("https://upload.wikimedia.org/wikipedia/commons/1/13/Artist%E2%80%99s_impression_of_the_black_hole_inside_NGC_300_X-1_%28ESO_1004c%29.webm")
                q = query(f)
                @test typeof(q) <: File{format"MATROSKA"}
            end
        end
        @testset "WAV detection" begin
            open(joinpath(file_dir, "sin.wav")) do s
                @test FileIO.detectwav(s)
            end
        end
        @testset "CSV detection" begin
            f = joinpath("files", "data.csv")
            q = query(f)
            @test typeof(q) <: File{format"CSV"}
        end
        @testset "RDA detection" begin
            q = query(joinpath(file_dir, "minimal_ascii.rda"))
            @test typeof(q) <: File{format"RData"}
            open(q) do io
                @test position(io) == 0
                @test FileIO.detect_rdata(io)
                # 6 for /r/n  and 5 for /n
                @test (position(io) in (5, 6))
            end
            # A GZipped file
            q = query(joinpath(file_dir, "iris.rda"))
            @test typeof(q) <: File{format"RData"}
        end
        @testset "RDS detection" begin
            q = query(joinpath(file_dir, "minimal_ascii.rds"))
            @test typeof(q) <: File{format"RDataSingle"}
            open(q) do io
                @test position(io) == 0
                @test FileIO.detect_rdata_single(io)
                # need to seek to beginning of file where data structure starts
                @test position(io)  == 0
            end
        end
        @testset "MIDI detection" begin
            q = query(joinpath(file_dir, "doxy.mid"))
            @test typeof(q) <: File{format"MIDI"}
            q = query(joinpath(file_dir, "doxy.midi"))
            @test typeof(q) <: File{format"MIDI"}
            q = query(joinpath(file_dir, "doxy2.MID"))
            @test typeof(q) <: File{format"MIDI"}
            @test magic(format"MIDI") == b"MThd"
            open(q) do io
                @test position(io) == 0
                skipmagic(io)
                @test position(io) == 4
            end
        end
        @testset "OpenEXR detection" begin
            q = query(joinpath(file_dir, "rand.exr"))
            @test typeof(q) <: File{format"EXR"}
            @test magic(format"EXR") == UInt8[0x76, 0x2F, 0x31, 0x01]
            open(q) do io
                @test position(io) == 0
                skipmagic(io)
                @test position(io) == 4
            end
        end
        @testset "Sixel detection" begin
            q = query(joinpath(file_dir, "rand.six"))
            @test typeof(q) <: File{format"SIXEL"}
            q = query(joinpath(file_dir, "rand.sixel"))
            @test typeof(q) <: File{format"SIXEL"}
            open(q) do io
                @test position(io) == 0
                skipmagic(io)
                @test position(io) == 3
            end
        end
        @testset "AVSfld detection" begin
            q = query(joinpath(file_dir, "avs-ascii.fld"))
            @test typeof(q) <: File{format"AVSfld"}
        end

        @testset "MuData detection" begin
            q = query(joinpath(file_dir, "file1.h5mu"))
            @test typeof(q) <: File{format"h5mu"}
            q = query(joinpath(file_dir, "h5mu.test"))
            @test typeof(q) <: File{format"h5mu"}
        end

        @testset "AnnData detection" begin
            q = query(joinpath(file_dir, "file1.h5ad"))
            @test typeof(q) <: File{format"h5ad"}
            q = query(joinpath(file_dir, "file2.h5ad"))
            @test typeof(q) <: File{format"h5ad"}
            q = query(joinpath(file_dir, "h5ad.h5"))
            @test typeof(q) <: File{format"HDF5"}
        end

        @testset "HDF5 detection" begin
            q = query(joinpath(file_dir, "file1.h5"))
            @test typeof(q) <: File{format"HDF5"}
            q = query(joinpath(file_dir, "file2.h5"))
            @test typeof(q) <: File{format"HDF5"}
        end

        @testset "Bibliography detection" begin
            q = query(joinpath(file_dir, "file.bib"))
            @test typeof(q) <: File{format"BIB"}
        end

        @testset "DICOM detection" begin
            q = query(joinpath(file_dir, "CT_JPEG70.dcm"))
            @test typeof(q) <: File{format"DCM"}
        end
    end

    @testset "Query from IOBuffer" begin
        streamformat(::Stream{T, U}) where {T, U} = T
        for name ∈ ["magic1.tiff", "magic2.tiff"]
            pth = joinpath(file_dir, "magic2.tiff")
            open(pth) do io
                buf=IOBuffer(read(io))
                @test streamformat(query(buf)) == DataFormat{:TIFF}
            end
        end
    end

    @testset "issue #338" begin
        open("test.png", "w") do io
            write(io, UInt8('R'))
        end
        q = query("test.png")
        @test FileIO.formatname(q) == :PNG
        q = query("test.png"; checkfile=false)
        @test FileIO.formatname(q) == :PNG
        rm("test.png")
    end

    @testset "issue #345" begin
        iris = joinpath("files", "iris.rda")

        q = query(iris)
        @test typeof(q) <: File{format"RData"}

        io = open(iris)
        q = query(io)
        @test typeof(q) <: Stream{format"RData"}
        @test FileIO.detect_rdata(io)

        # issue #345: it errors here
        io = CodecZlib.GzipDecompressorStream(open(iris))
        q = query(io)
        @test FileIO.unknown(q) # FIXME: should be RData
        @test FileIO.detect_rdata(io)
    end

    @testset "Gadget2" begin
        q = query(joinpath(file_dir, "gassphere_littleendian.gadget2"))
        @test typeof(q) <: File{format"Gadget2"}
    end
end
