using POMDPs
using QuickPOMDPs
using POMDPTools

using LinearAlgebra


struct CompressedSolver <: POMDPs.Solver
    sampler::Sampler
    compressor::Compressor
    approximator::Approximator
    updater::POMDPs.Updater
    base_solver::POMDPs.Solver
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

    # compute rewards for belief MDP
    function R̃s(b̃s, a)
        b = decompress(solver.compressor, b̃s)
        b = DiscreteBelief(pomdp, normalize(b, 1))
        r = sum([reward(pomdp, s, a) * pdf(b, s) for s in state(pomdp)])
        return r
    end

    # compute transitions for belief MDP
    # TODO: define a new BeliefUpdater
    T̃s = Dict()
    for b̃s in eachrow(B̃s), a in actions(pomdp)
        b = decompress(solver.compressor, b̃s)
        # normalize!(b, 1)
        for z in observations(pomdp)   # TODO: use observations or observation (singular); space or distribution; how to handle both?
            α = 1  # TODO: make hyperparameter
            bp = []
            ba = []
            for (i, sp) in enumerate(states(pomdp))
                O = observation(pomdp, a, sp)
                prob = α * pdf(O, z)
                multiplier = 0.0
                for s in states(pomdp)
                    T = transition(pomdp, s, a)
                    multiplier += pdf(T, sp) * b[i]
                    push!(ba, multiplier)
                end
                prob *= multiplier
                # bp = normalize(bp, 1)
                push!(bp, prob)
            end

            b̃p = compress(solver.compressor, bp')
            weights = weights(solver.approximator, b̃p)

            for b̃sp in eachrow(B̃s)
                T̃s[b̃s, a, b̃sp] = 0.0
                w = weight(solver.approximator, b̃sp, b̃p)

                total = 0.0
                for (sp, mass) in zip(states(pomdp), ba)
                    O = observation(pomdp, sp)
                    total += pdf(O, z) * mass
                end
                w = 1  # TODO change this to be a function w(approximator, b1, b2) --> for single it'll just return if it's the nearest
                T̃s[b̃s, a, b̃sp] += w * total
            end
        end
    end


    # T̃s = Dict()
    # for b̃s in eachrow(B̃s), a in actions(pomdp)
    #     for o in observations(pomdp)   # TODO: use observations or observation (singular); space or distribution; how to handle both?
    #         b = decompress(solver.compressor, b̃s)
    #         b = DiscreteBelief(pomdp, normalize(b, 1))
    #         bp = POMDPs.update(solver.updater, b, a, o)
    #         b̃p = compress(solver.compressor, bp.b')
    #         b̃sp = approximate(solver.approximator, b̃p)

    #         # TODO: figure out if ignoring the weighting scheme is a problem
    #         prob = 0.0
    #         for sp in states(pomdp)
    #             O = observation(pomdp, a, sp)
    #             prob += pdf(O, o)
    #             multiplier = 0.0
    #             for s in states(pomdp)
    #                 T = transition(pomdp, s, a)
    #                 multiplier += pdf(T, sp) * pdf(b, s)
    #             end
    #             prob *= multiplier
    #         end
    #         T̃s[b̃s, a, b̃sp] = prob 
    #     end
    # end

    S = Tuple(eachrow(B̃s))
    A = actions(pomdp)
    γ = discount(pomdp)
    T(s, a, sp) = T̃s[s, a, sp]
    R(s, a) = R̃s(s, a)
    # p₀ = Deterministic(S[1])  # TODO: change this to save b0 at start

    # for s in S, a in A, sp in S
    #     println(T(s, a, sp))
    # end

    # @infiltrate
    # ss = vec(collect(S))
    # as = vec(collect(A))
    # for x in ss, u in as, xp in ss
    #     print(T(x, u, xp))
    # end

    mdp = DiscreteExplicitMDP(S, A, T, R, γ)
    return solve(solver.base_solver, mdp)
end