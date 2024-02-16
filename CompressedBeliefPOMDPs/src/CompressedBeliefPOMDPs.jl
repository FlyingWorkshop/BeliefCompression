module CompressedBeliefPOMDPs

using Infiltrator

# using POMDPs
# using Optim

using 


export
    Compressor,
    compress,
    decompress,
include("compressor.jl")

# export
#     Compression,
#     PoissonPCA,
#     BernoulliPCA,
#     compress
# include("compression.jl")

export
    Approximation,
    SingleNearestNeighbor,
    approximate
include("approximation.jl")

export
    CompressedSolver,
    solve
include("compressed_solver.jl")


end # module CompressedBeliefPOMDPs
