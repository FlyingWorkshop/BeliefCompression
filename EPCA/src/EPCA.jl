module EPCA

using LinearAlgebra

greet() = print("Hello World!")

export
    poisson_epca,
    poisson_loss
include("poisson.jl")

end # module EPCA
