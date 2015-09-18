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

add_format(format"NRRD", "NRRD", [".nrrd", ".nhdr"])
add_loader(format"NRRD", :NRRD)
add_saver(format"NRRD", :NRRD)

add_format(format"AndorSIF", "Andor Technology Multi-Channel File", ".sif")
add_loader(format"AndorSIF", :AndorSIF)

add_format(format"BMP", UInt8[0x42,0x4d], ".bmp")
add_loader(format"BMP", :ImageMagick)
add_saver(format"BMP", :ImageMagick)
add_format(format"AVI", UInt8[0x52,0x49,0x46,0x46], ".avi")
add_loader(format"AVI", :ImageMagick)
add_saver(format"AVI", :ImageMagick)
add_format(format"CRW", UInt8[0x49,0x49,0x1a,0x00,0x00,0x00,0x48,0x45], ".crw")
add_loader(format"CRW", :ImageMagick)
add_saver(format"CRW", :ImageMagick)
add_format(format"CUR", UInt8[0x00,0x00,0x02,0x00], ".cur")
add_loader(format"CUR", :ImageMagick)
add_saver(format"CUR", :ImageMagick)
add_format(format"DCX", UInt8[0xb1,0x68,0xde,0x3a], ".dcx")
add_loader(format"DCX", :ImageMagick)
add_saver(format"DCX", :ImageMagick)
add_format(format"DOT", UInt8[0xd0,0xcf,0x11,0xe0,0xa1,0xb1,0x1a,0xe1], ".dot")
add_loader(format"DOT", :ImageMagick)
add_saver(format"DOT", :ImageMagick)
add_format(format"EPS", UInt8[0x25,0x21,0x50,0x53,0x2d,0x41,0x64,0x6f], ".eps")
add_loader(format"EPS", :ImageMagick)
add_saver(format"EPS", :ImageMagick)
add_format(format"GIF", UInt8[0x47,0x49,0x46,0x38], ".gif")
add_loader(format"GIF", :ImageMagick)
add_saver(format"GIF", :ImageMagick)
add_format(format"HDR", UInt8[0x23,0x3f,0x52,0x41,0x44,0x49,0x41,0x4e], ".hdr")
add_loader(format"HDR", :ImageMagick)
add_saver(format"HDR", :ImageMagick)
add_format(format"ICO", UInt8[0x00,0x00,0x01,0x00], ".ico")
add_loader(format"ICO", :ImageMagick)
add_saver(format"ICO", :ImageMagick)
add_format(format"INFO", UInt8[0x7a,0x62,0x65,0x78], ".info")
add_loader(format"INFO", :ImageMagick)
add_saver(format"INFO", :ImageMagick)
add_format(format"JP2", UInt8[0x00,0x00,0x00,0x0c,0x6a,0x50,0x20,0x20], ".jp2")
add_loader(format"JP2", :ImageMagick)
add_saver(format"JP2", :ImageMagick)
add_format(format"JPEG", UInt8[0xff,0xd8,0xff],  [".jpeg", ".jpg", ".JPG"]) # 0xe1
add_loader(format"JPEG", :ImageMagick)
add_saver(format"JPEG", :ImageMagick)
add_format(format"PCX", UInt8[0x0a,0x05,0x01,0x01], ".pcx")
add_loader(format"PCX", :ImageMagick)
add_saver(format"PCX", :ImageMagick)
add_format(format"PDB", UInt8[0x73,0x7a,0x65,0x7a], ".pdb")
add_loader(format"PDB", :ImageMagick)
add_saver(format"PDB", :ImageMagick)
add_format(format"PDF", UInt8[0x25,0x50,0x44,0x46], ".pdf")
add_loader(format"PDF", :ImageMagick)
add_saver(format"PDF", :ImageMagick)
add_format(format"PGM", UInt8[0x50,0x35,0x0a], ".pgm")
add_loader(format"PGM", :ImageMagick)
add_saver(format"PGM", :ImageMagick)
add_format(format"PNG", UInt8[0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a], ".png")
add_loader(format"PNG", :ImageMagick)
add_saver(format"PNG", :ImageMagick)
add_format(format"PSD", UInt8[0x38,0x42,0x50,0x53], ".psd")
add_loader(format"PSD", :ImageMagick)
add_saver(format"PSD", :ImageMagick)
add_format(format"RGB", UInt8[0x01,0xda,0x01,0x01,0x00,0x03], ".rgb")
add_loader(format"RGB", :ImageMagick)
add_saver(format"RGB", :ImageMagick)

add_format(format"TIFF", (UInt8[0x4d,0x4d,0x00,0x2a], UInt8[0x4d,0x4d,0x00,0x2b], UInt8[0x49,0x49,0x2a,0x00]), ".tiff")
add_loader(format"TIFF", :ImageMagick)
add_saver(format"TIFF", :ImageMagick)
add_format(format"WMF", UInt8[0xd7,0xcd,0xc6,0x9a], ".wmf")
add_loader(format"WMF", :ImageMagick)
add_saver(format"WMF", :ImageMagick)
add_format(format"WPG", UInt8[0xff,0x57,0x50,0x43], ".wpg")
add_loader(format"WPG", :ImageMagick)
add_saver(format"WPG", :ImageMagick)

#Shader files
add_format(format"GLSLShader", (), [".frag", ".vert", ".geom", ".comp"])
add_loader(format"GLSLShader", :GLAbstraction)
add_saver(format"GLSLShader", :GLAbstraction)

# Mesh formats
add_format(format"OBJ", (), ".obj")
add_loader(format"OBJ", :MeshIO)
add_saver(format"OBJ", :MeshIO)

add_format(format"PLY_ASCII", "ply\nformat ascii 1.0", ".ply")
add_format(format"PLY_BINARY", "ply\nformat binary_little_endian 1.0", ".ply")

add_loader(format"PLY_ASCII", :MeshIO)
add_loader(format"PLY_BINARY", :MeshIO)
add_saver(format"PLY_ASCII", :MeshIO)
add_saver(format"PLY_BINARY", :MeshIO)

add_format(format"2DM", "MESH2D", ".2dm")
add_loader(format"2DM", :MeshIO)
add_saver(format"2DM", :MeshIO)

add_format(format"OFF", "OFF", ".off")
add_loader(format"OFF", :MeshIO)
add_saver(format"OFF", :MeshIO)




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


function detect_stlascii(io)
    try
        position(io) != 0 && return false
        seekend(io)
        len = position(io)
        seekstart(io)
        len < 80 && return false
        header = readbytes(io, 80) # skip header
        seekstart(io)
        header[1:6] == b"solid " && !detect_stlbinary(io)
    finally
        seekstart(io)
    end
end
function detect_stlbinary(io)
    const size_header = 80+sizeof(Uint32)
    const size_triangleblock = (4*3*sizeof(Float32)) + sizeof(Uint16)

    position(io) != 0 && return false
    seekend(io)
    len = position(io)
    seekstart(io)
    len < size_header && return false
    
    skip(io, 80) # skip header
    number_of_triangle_blocks = read(io, Uint32)
     #1 normal, 3 vertices in Float32 + attrib count, usually 0
    len != (number_of_triangle_blocks*size_triangleblock)+size_header && return false
    skip(io, number_of_triangle_blocks*size_triangleblock-sizeof(Uint16))
    attrib_byte_count = read(io, Uint16) # read last attrib_byte
    attrib_byte_count != zero(Uint16) && return false # should be zero as not used
    eof(io) && return true
    false
end
add_format(format"STL_ASCII", detect_stlascii, [".stl", ".STL"])
add_format(format"STL_BINARY", detect_stlbinary, [".stl", ".STL"])
add_loader(format"STL_ASCII", :MeshIO)
add_saver(format"STL_BINARY", :MeshIO)
add_saver(format"STL_ASCII", :MeshIO)
add_loader(format"STL_BINARY", :MeshIO)

