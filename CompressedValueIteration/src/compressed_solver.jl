using POMDPs


struct CompressedSolver <: Solver
    compression::Compression
    compressed_dims::Int  # NOTE: maybe put compressed dim and max iter in a "subclass of EPCA?"
    maxiter::Int
    # approximation_strategy::Approximation
end

function solve(solver::CompressedSolver, pomdp::POMDP)
    # collect sample beliefs (TODO)
    n_samples, n_states = (10, 5)
    B = rand(n_samples, n_states)

    # compress belief space
    return compress(B, solver.compressed_dims, solver.compression, solver.maxiter)
end