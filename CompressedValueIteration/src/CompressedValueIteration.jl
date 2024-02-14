module CompressedValueIteration

using Infiltrator

using POMDPs
using Optim



export
    PoissonPCA,
    BernoulliPCA,
    Compression
include("epca_compression.jl")

end # module CompressedValueIteration
