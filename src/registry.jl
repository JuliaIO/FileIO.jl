### Simple cases
add_format(format"JLD", "Julia data file (HDF5)", ".jld")
add_loader(format"JLD", :JLD)
add_saver(format"JLD", :JLD)

# Image formats
add_format(format"PBMText",   b"P1", ".pbm")
add_format(format"PGMText",   b"P2", ".pgm")
add_format(format"PPMText",   b"P3", ".ppm")
add_format(format"PBMBinary", b"P4", ".pbm")
add_format(format"PGMBinary", b"P5", ".pgm")
add_format(format"PPMBinary", b"P6", ".ppm")


### Complex cases
# HDF5: the complication is that the magic bytes may start at
# 0, 512, 1024, 2048, or any multiple of 2 thereafter
h5magic = (0x89,0x48,0x44,0x46,0x0d,0x0a,0x1a,0x0a)
function detecthdf5(io)
    position(io) == 0 || return false
    seekend(io)
    len = position(io)
    seekstart(io)
    magic = Array(UInt8, length(h5magic))
    pos = position(io)
    while pos+length(h5magic) <= len
        read!(io, magic)
        if iter_eq(magic, h5magic)
            return true
        end
        pos = pos == 0 ? 512 : 2*pos
        if pos < len
            seek(io, pos)
        end
    end
    false
end
add_format(format"HDF5", detecthdf5, [".h5", ".hdf5"])
add_loader(format"HDF5", :HDF5)
add_saver(format"HDF5", :HDF5)



FileIO.add_format(format"FRAG", (), ".frag")
FileIO.add_format(format"VERT", (), ".vert")
FileIO.add_format(format"GEOM", (), ".geom")
FileIO.add_format(format"COMP", (), ".comp")

FileIO.add_loader(format"FRAG", :GLAbstraction)
FileIO.add_loader(format"VERT", :GLAbstraction)
FileIO.add_loader(format"GEOM", :GLAbstraction)
FileIO.add_loader(format"COMP", :GLAbstraction)

FileIO.add_saver(format"FRAG", :GLAbstraction)
FileIO.add_saver(format"VERT", :GLAbstraction)
FileIO.add_saver(format"GEOM", :GLAbstraction)
FileIO.add_saver(format"COMP", :GLAbstraction)
