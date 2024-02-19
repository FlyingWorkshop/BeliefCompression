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
    approximate,
    SingleNearestNeighbor
include("approximation/approximator.jl")

export
    Sampler,
    BaseSampler,
    RandomSampler,
    sample
include("sampler.jl")

export
    CompressedSolver,
    solve
include("solver.jl")


end # module CompressedBeliefPOMDPs
