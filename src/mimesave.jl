module MimeWriter

using ..FileIO: File, @format_str

function save(file::File{format"PNG"}, data)
    if showable("image/png", data)
        open(file.filename, "w") do s
            show(IOContext(s, :full_fidelity=>true), "image/png", data)
        end
    else
        throw(ArgumentError("Argument does not support conversion to png."))
    end
end

function save(file::File{format"SVG"}, data)
    if showable("image/svg+xml", data)
        open(file.filename, "w") do s
            show(IOContext(s, :full_fidelity=>true), "image/svg+xml", data)
        end
    else
        throw(ArgumentError("Argument does not support conversion to svg."))
    end
end

function save(file::File{format"PDF"}, data)
    if showable("application/pdf", data)
        open(file.filename, "w") do s
            show(IOContext(s, :full_fidelity=>true), "application/pdf", data)
        end
    else
        throw(ArgumentError("Argument does not support conversion to pdf."))
    end
end

function save(file::File{format"EPS"}, data)
    if showable("application/eps", data)
        open(file.filename, "w") do s
            show(IOContext(s, :full_fidelity=>true), "application/eps", data)
        end
    else
        throw(ArgumentError("Argument does not support conversion to eps."))
    end
end

end
