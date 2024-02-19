using POMDPs
using QuickPOMDPs
using POMDPTools

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

    # compress belief space
    fit!(solver.compressor, B)
    B̃ = compress(solver.compressor, B)

    # compute state space for belief MDP
    res = 5
    axis = LinRange(0, 1, res)
    grid = reinterpret(reshape, Float64, [(i, j) for i=axis for j=axis])  # TODO: use GridInterpolations.jl
    B̃s = approximate(solver.approximator, grid', B̃)  # TODO: perhaps move the grid into a field of approximator?
    # TODO: can I move all of the decompression outside of R and T?

    # compute rewards for belief MDP
    function R(b̃s, a)
        b = decompress(solver.compressor, b̃s)
        r = sum([reward(pomdp, s, a) * pdf(b, s) for s in state(pomdp)])
        return r
    end

    # compute transitions for belief MDP
    T̃s = Dict()

    for b̃s in eachrow(B̃s), a in actions(pomdp)
        for o in observations(pomdp)   # TODO: use observations or observation (singular); space or distribution; how to handle both?
            b = decompress(solver.compressor, b̃s')  # TODO: potentially just decompress entire matrix before iterating across rows
            b = vec(b / sum(b))  # normalize;  # TODO: why doesn't it already sum to 1? Does this mean I have a bug?
            b = DiscreteBelief(pomdp, b)
            bp = POMDPs.update(solver.updater, b, a, o)
            b̃p = compress(solver.compressor, bp.b')
            b̃sp = approximate(solver.approximator, grid', b̃p)

            # TODO: figure out if ignoring the weighting scheme is a problem
            prob = 0.0
            for sp in states(pomdp)
                O = observation(pomdp, a, sp)
                prob += pdf(O, o)
                multiplier = 0.0
                for s in states(pomdp)
                    T = transition(pomdp, s, a)
                    multiplier += pdf(T, sp) * pdf(b, s)
                end
                prob *= multiplier
            end
            T̃s[b̃s, a, b̃sp] = prob 
        end
    end

    T(s, a, sp) = T̃s[s, a, sp]

    # create a low-dimensional belief MDP approximation of the POMDP
    # b0 = initialstate(pomdp)
    # mdp = QuickMDP(
    #     states = B̃s,
    #     actions = actions(pomdp),
    #     discount = discount(pomdp),
    #     transition = T,
    #     reward = R,
    # )
    # TODO: use discrete explicit MDPs instead (https://juliapomdp.github.io/QuickPOMDPs.jl/v0.2/discrete_explicit/)
    mdp = QuickMDP(
        function (s, a, rng)        
            x, v = s
            vp = clamp(v + a*0.001 + cos(3*x)*-0.0025, -0.07, 0.07)
            xp = x + vp
            if xp > 0.5
                r = 100.0
            else
                r = -1.0
            end
            return (sp=(xp, vp), r=r)
        end,
        actions = [-1., 0., 1.],
        initialstate = Deterministic((-0.5, 0.0)),
        discount = 0.95,
        isterminal = s -> s[1] > 0.5
    )
    # TODO: need to conver this to an action in the "real world"
    return solve(solver.base_solver, mdp)
end