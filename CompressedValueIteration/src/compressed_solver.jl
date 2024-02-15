using POMDPs
using QuickPOMDPs
using POMDPModelTools: Deterministic


struct CompressedSolver <: Solver
    compression::Compression
    compressed_dims::Int  # NOTE: maybe put compressed dim and max iter in a "subclass of EPCA?"
    maxiter::Int
    approximation_strategy::Approximation
end

function solve(solver::CompressedSolver, pomdp::POMDP)
    # collect sample beliefs (TODO)
    n_samples, n_states = (10, 5)
    B = rand(n_samples, n_states)

    # compress belief space
    B̃ = compress(B, solver.compressed_dims, solver.compression, solver.maxiter)

    # convert low-dimensional space into discrete state space
    S = approximate(solver.approximation_strategy, B, B̃)

    # learn belief transitions and reward function
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