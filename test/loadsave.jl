using FileIO
using FactCheck

# Stub readers---these might bork any existing readers, so don't
# run these tests while doing other things!
FileIO.load(file::File{format"PBMText"})   = "PBMText"
FileIO.load(file::File{format"PBMBinary"}) = "PBMBinary"
FileIO.load(file::File{format"HDF5"})      = "HDF5"
FileIO.load(file::File{format"JLD"})       = "JLD"

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
end
