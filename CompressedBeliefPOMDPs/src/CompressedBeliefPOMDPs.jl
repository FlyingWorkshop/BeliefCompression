module CompressedBeliefPOMDPs

using Infiltrator

# using POMDPs
# using Optim

export
    Compressor,
    fit!,
    compress,
    decompress
include("compressor.jl")

# export
#     Approximator,
#     approximate,
#     SingleNearestNeighbor
# include("approximator.jl")


# export
#     CompressedSolver,
#     solve
# include("solver.jl")


end # module CompressedBeliefPOMDPs
