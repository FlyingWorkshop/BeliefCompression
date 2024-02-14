module CompressedValueIteration

using Infiltrator

# using POMDPs
# using Optim


export
    PoissonPCA,
    BernoulliPCA,
    compress
include("compression.jl")


export
    CompressedSolver,
    solve
include("compressed_solver.jl")


end # module CompressedValueIteration
