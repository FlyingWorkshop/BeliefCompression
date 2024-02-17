using POMDPs
using QuickPOMDPs
using POMDPTools: Deterministic


struct CompressedSolver <: POMDPs.Solver
    # TODO: probably need a base solver that takes care of the MDP
    compressor::Compressor
    approximator::Approximator
    updater::POMDPs.Updater
end


function POMDPs.solve(solver::CompressedSolver, pomdp::POMDP)
    # collect sample beliefs (TODO)
    n_samples, n_states = (10, 5)
    B = rand(n_samples, n_states)

    # compress belief space
    fit!(solver.compressor, B)
    B̃ = compress(solver.compressor, B)

    # compute state space for belief MDP
    res = 5
    axis = LinRange(0, 1, res)
    grid = reinterpret(reshape, Float64, [(i, j) for i=axis for j=axis])  # TODO: use GridInterpolations.jl
    B̃s = approximate(solver.approximator, grid', B̃)
    # TODO: can I move all of the decompression outside of R and T?

    # compute rewards for belief MDP
    function R(b̃s, a)
        r = 0.0
        b = decompress(solver.compressor, b̃s)
        for (i, s) in enumerate(states(pomdp))
            r += reward(pomdp, s, a) * b[i]
        end
        return r
    end

    # compute transitions for belief MDP
    T̃s = Dict()

    for b̃s in eachrow(B̃s), a in actions(pomdp)
        for o in observations(pomdp)   # TODO: use observations or observation (singular); space or distribution; how to handle both?
            b = decompress(solver.compressor, b̃s')  # TODO: potentially just decompress entire matrix before iterating across rows
            bp = POMDPs.update(solver.updater, b, a, o)
            b̃p = compress(solver.compressor, bp)
            b̃sp = approximate(solver.approximator, b̃p)

            prob = 0.0
            for sp in states(pomdp)
                O = observation(a, sp)
                prob += pdf(O, o)
                multiplier = 0.0
                for (i, s) in enumerate(states(pomdp))
                    T = transition(pomdp, s, a)
                    multiplier += pdf(T, sp) * b[i]
                end
                prob *= multiplier
            end
            T̃s[b̃s, a, b̃sp] = prob 
        end
    end

    function T(s, a, sp)
        return T̃s[s, a, sp]
    end

    # create a low-dimensional belief MDP approximation of the POMDP
    mdp = QuickMDP(
        initialstate = Uniform(B̃s),  # TODO: maybe change
        states = B̃s,
        discount = discount(pomdp),
        transition = T,
        reward = R,
    )

    return "Hello World!"
end