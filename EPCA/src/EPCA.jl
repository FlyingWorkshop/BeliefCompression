module EPCA

# using LinearAlgebra

greet() = print("Hello World!")

# export
#     poisson_epca,
#     poisson_loss
# include("poisson.jl")

# export
#     PoissonPCA
# include("bar.jl")

export
    PoissonPCA,
    BernoulliPCA,
    Compression
include("baz.jl")

end # module EPCA
