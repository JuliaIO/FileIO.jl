function FileIO.save(file::File{format"PNG"}, data)
    if mimewritable("image/png", data)
        open(file.filename, "w") do s
            show(s, "image/png", data)
        end
    else
        throw(ArgumentError("Argument does not support conversion to png."))
    end
end

function FileIO.save(file::File{format"SVG"}, data)
    if mimewritable("image/svg+xml", data)
        open(file.filename, "w") do s
            show(s, "image/svg+xml", data)
        end
    else
        throw(ArgumentError("Argument does not support conversion to svg."))
    end
end

function FileIO.save(file::File{format"PDF"}, data)
    if mimewritable("application/pdf", data)
        open(file.filename, "w") do s
            show(s, "application/pdf", data)
        end
    else
        throw(ArgumentError("Argument does not support conversion to pdf."))
    end
end

function FileIO.save(file::File{format"EPS"}, data)
    if mimewritable("application/eps", data)
        open(file.filename, "w") do s
            show(s, "application/eps", data)
        end
    else
        throw(ArgumentError("Argument does not support conversion to eps."))
    end
end
