module EPCA

# using LinearAlgebra

greet() = print("Hello World!")

# export
#     poisson_epca,
#     poisson_loss
# include("poisson.jl")

export
    PoissonPCA
include("bar.jl")

end # module EPCA
