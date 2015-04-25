
Pkg.init()

function check_if_package_exists(case_insensitive_regex::String)
	global avaliable_list
	if !isdefined(:avaliable_list)
		println("Getting list of available packages...")
		avaliable_list = Pkg.available()
	end

	regex = Regex(case_insensitive_regex, "i")
	for s in avaliable_list
		if ismatch(regex, s)
			println("Package \"", s, "\" is available")
		end
	end
end

Pkg.add("GZip")
Pkg.add("ZipFile")

Pkg.add("PyPlot")
Pkg.add("SymPy")

Pkg.add("HDF5")
Pkg.add("Silo")

Pkg.add("DSP")
Pkg.add("Wavelets")

Pkg.add("Distributions")
Pkg.clone("git://github.com/jlep/Multicombinations.jl")
Pkg.add("Iterators")
Pkg.add("Cartesian")

Pkg.add("Polynomials")
Pkg.add("PowerSeries")



