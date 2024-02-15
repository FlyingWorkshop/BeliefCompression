using POMDPs
using QuickPOMDPs
using POMDPTools: Deterministic


struct CompressedSolver <: Solver
    compression::Compression
    n_dims::Int  # NOTE: maybe put compressed dim and max iter in a "subclass of EPCA?"
    maxiter::Int
    approximation_strategy::Approximation
end


function solve(solver::CompressedSolver, pomdp::POMDP)
    # collect sample beliefs (TODO)
    n_samples, n_states = (10, 5)
    B = rand(n_samples, n_states)

    # compress belief space
    # TODO: rather than returning U, return a way to recover the original belief so that would be f(x) = g(Ux) [might be G double check]
    B̃, U = compress(B, solver.n_dims, solver.compression, solver.maxiter)

    # convert low-dimensional space into discrete state space
    res = 5
    axis = LinRange(0, 1, res)
    grid = reinterpret(reshape, Float64, [(i, j) for i=axis for j=axis])
    S = approximate(solver.approximation_strategy, grid', B̃)

    # learn belief transitions and reward function
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
        reward = function(disc_b̃, a)
            result = 0
            for (i, s) in enumerate(states(pomdp))
                b = recover_original_belief(disc_b̃)  # TODO
                result += reward(pomdp, s, a) * b[i]
            end
            return result
        end,
        actions = actions(pomdp),
        initialstate = initialstate(pomdp),
        discount = discount(pomdp),
        # isterminal = s -> s[1] > 0.5
    )

    a = initialstate(pomdp)

    mountaincar = QuickMDP(
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

    return "Hello World!"
end