module CompressedBeliefPOMDPs


using Infiltrator

export
    Compressor,
    fit!,
    compress,
    decompress
include("compressor.jl")

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

export
    CompressedBeliefMDP
include("cbmdp.jl")

end # module CompressedBeliefPOMDPs
