using POMDPs
using POMDPTools
using QuickPOMDPs
using LocalFunctionApproximation: LocalFunctionApproximator

using LinearAlgebra

# TEMP
using DiscreteValueIteration


struct CompressedSolver <: POMDPs.Solver
    sampler::Sampler
    compressor::Compressor
    approximator::Approximator
    updater::POMDPs.Updater
end


function decode(solver::CompressedSolver, pomdp::POMDP, b̃s)
    b = normalize(decompress(solver.compressor, b̃s), 1)
    return DiscreteBelief(pomdp, b)
end


function POMDPs.solve(solver::CompressedSolver, pomdp::POMDP)
    # collect sample beliefs
    B = sample(solver.sampler, pomdp)
    # TODO: should I remove non-unique rows b/c it may fuck up transition weights (e.g., consider if the nearest neighbor is redundant then weights in transition function could be messed up)

    # compress belief space
    fit!(solver.compressor, B)
    B̃ = compress(solver.compressor, B)

    # compute state space for belief MDP
    fit!(solver.approximator, B̃)
    B̃s = approximate(solver.approximator, B̃)

    # compute belief-state MDP
    function R̃s(b̃s, a)
        b = decode(solver, pomdp, b̃s)
        return sum([reward(pomdp, s, a) * pdf(b, s) for s in states(pomdp)])
    end

    T̃s = Dict()
    for b̃s in eachrow(B̃s), a in actions(pomdp), b̃sp in eachrow(B̃s)
        T̃s[b̃s, a, b̃sp] = 1 / size(B̃s)[1]
    end


    # compute transitions for belief MDP
    # TODO: define a new BeliefUpdater
    # T̃s = Dict()
    # for b̃s in eachrow(B̃s), a in actions(pomdp)
    #     b = normalize(decompress(solver.compressor, b̃s), 1)
    #     for z in observations(pomdp)   # TODO: use observations or observation (singular); space or distribution; how to handle both?
    #         α = 1  # TODO: make hyperparameter
    #         bp = []
    #         ba = []
    #         for (i, sp) in enumerate(states(pomdp))
    #             O = observation(pomdp, a, sp)
    #             prob = α * pdf(O, z)
    #             multiplier = 0.0
    #             for s in states(pomdp)
    #                 T = transition(pomdp, s, a)
    #                 multiplier += pdf(T, sp) * b[i]
    #                 push!(ba, multiplier)
    #             end
    #             prob *= multiplier
    #             # bp = normalize(bp, 1)
    #             push!(bp, prob)
    #         end

    #         b̃p = compress(solver.compressor, bp')
    #         weights = weights(solver.approximator, b̃p)

    #         for (w, b̃sp) in zip(weights, eachrow(B̃s))
    #             T̃s[b̃s, a, b̃sp] = 0.0
    #             if w == 0
    #                 continue
    #             end
    #             total = 0.0
    #             for (sp, mass) in zip(states(pomdp), ba)
    #                 O = observation(pomdp, sp)
    #                 total += pdf(O, z) * mass
    #             end
    #             T̃s[b̃s, a, b̃sp] += w * total
    #         end
    #     end
    # end
    # T̃s = Dict(key => clamp(value, 0., 1.) for (key, value) in T̃s)

    S = Tuple(eachrow(B̃s))
    A = actions(pomdp)
    T(s, a, sp) = T̃s[s, a, sp]
    R(s, a) = R̃s(s, a)
    γ = discount(pomdp)
    # p₀ = Deterministic(S[1])  # TODO: change this to save b0 at start

    mdp = DiscreteExplicitMDP(S, A, T, R, γ)

    # TEMP
    base_solver = ValueIterationSolver(max_iterations=100, belres=1e-6, verbose=true)


    return solve(base_solver, mdp)
end