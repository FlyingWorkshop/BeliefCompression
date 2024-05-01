using Revise
using ExpFamilyPCA
using Random

Random.seed!(1)

n = 10
d = 5
X = rand(0:100, n, d)
@show X
epca = PoissonEPCA()
X̃ = fit!(epca, X; verbose=true, maxoutdim=d, ϵ=0, maxiter=400)
X̂ = decompress(epca, X̃)