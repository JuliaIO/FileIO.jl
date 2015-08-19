magics= readdlm(Pkg.dir("FileIO", "src", "all_magic_bytes", "all_signatures.txt"), ',', UTF8String)
println(typeof(magics))
f = open(Pkg.dir("FileIO", "src", "all_magic_bytes", "registry.jl"), "w")
magics = [vec(magics[i, 1:end]) for i=1:size(magics, 1)]
for (ext, magic, info) in magics
    ext = string(ext)
    if ext != "*"
        mg = replace(string(magic), " ", "")
        magic = hex2bytes(mg)
        println(f, "add_format(format\"", ext, "\", ", string(magic), ", \".", lowercase(ext), "\")", " # ", info)
    end
end
close(f)
