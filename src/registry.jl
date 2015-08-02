### Simple cases
addformat(format"JLD", "Julia data file (HDF5)", ".jld")

# Image formats
addformat(format"PBMText",   b"P1", ".pbm")
addformat(format"PGMText",   b"P2", ".pgm")
addformat(format"PPMText",   b"P3", ".ppm")
addformat(format"PBMBinary", b"P4", ".pbm")
addformat(format"PGMBinary", b"P5", ".pgm")
addformat(format"PPMBinary", b"P6", ".ppm")


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
addformat(format"HDF5", detecthdf5, [".h5", ".hdf5"])
