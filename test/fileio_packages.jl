const all_packages = unique([values(FileIO.sym2loader)..., values(FileIO.sym2saver)...])

for pkg in all_packages
	if pkg != :ImageMagick && pkg != :GLAbstraction && pkg != :AndorSIF # temporary solution
		context("Testing dependant packge: $pkg :") do
			result = false
			try
				Pkg.installed("$pkg") == nothing && Pkg.add("$pkg")
				Pkg.test("$pkg")
				result = true
			end
			@fact result --> true
		end
	end
end