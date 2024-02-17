using POMDPs
using QuickPOMDPs
using POMDPTools: Deterministic


struct CompressedSolver <: Solver
    compressor::Compressor
    approximator::Approximator
end


# function bj(s; α=1)
#     prob = α * O(s, a, z)
#     d = transition(pomdp, s, a)
#     for (i, sp) in enumerate(states(pomdp))
#         pdf(d, sp) * bi[i]
#     end
# end

function solve(solver::CompressedSolver, pomdp::POMDP)
    # collect sample beliefs (TODO)
    n_samples, n_states = (10, 5)
    beliefs = rand(n_samples, n_states)

    # compress belief space
    fit!(solver.compressor, beliefs)
    compressed = compress(solver.compressor, beliefs)

    # convert low-dimensional space into discrete state space
    res = 5
    axis = LinRange(0, 1, res)
    grid = reinterpret(reshape, Float64, [(i, j) for i=axis for j=axis])  # TODO: use GridInterpolations.jl
    approximated = approximate(solver.approximator, grid', compressed)
    reconstructed = decompress(solver.compressor, approximated)

    # create a low-dimensional belief MDP approximation of the POMDP
    α = 1  # TODO: put elsewhere
    mdp = QuickMDP(
        initialstate = initialstate(pomdp),
        states = states(pomdp),
        discount = discount(pomdp),
        transition = function(s, a)


            # NOTE: doesn't work when base (PO)MDP uses an implicit distribution
            ImplicitDistribution(s, a) do s, a, rng
                # TODO: get Mykel to double check this
                T = transition(pomdp, s, a)
                sp = rand(rng, T)
                O = observation(pomdp, s, a, sp)  # TODO: ask Mykel if this is the right distribution
                z = rand(rng, O)

                pdf(d, z)


                return s + a
            end
        end,
        reward = function(b̃, a)
            r = 0.0
            b = decompress(solver.compressor, b̃)
            for (i, s) in enumerate(states(pomdp))
                r += reward(pomdp, s, a) * b[i]
            end
            return r
        end,
        discount = discount(pomdp),
    )

    return "Hello World!"
end