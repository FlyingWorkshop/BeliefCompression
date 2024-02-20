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

export
    Approximator,
    fit!,
    approximate,
    SingleNearestNeighbor
include("approximation/approximator.jl")
include("approximation/nearest_neighbor_approximator.jl")

export
    Sampler,
    BaseSampler,
    DiscreteRandomSampler,
    sample
include("sampling.jl")

export
    CompressedSolver,
    solve
include("solver.jl")


end # module CompressedBeliefPOMDPs
