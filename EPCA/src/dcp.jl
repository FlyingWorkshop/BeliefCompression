using Convex
using SCS

function poisson_epca(B, n_components, maxiter=50, ϵ=10e-5)
    """
    B̃ is a n_states x n_samples matrix -- compressed beliefs
    U is a n_states x n_components matrix -- basis
    """
    regularizer = ϵ * I(n_components)

    # Fix an initial estimate for B̃ and U randomly
    n_states, n_samples = size(B)
    B̃ = rand(n_samples, n_components)
    U = rand(n_states, n_components)

    for _ in 1:maxiter
        # find B̃ and fix U
        B̃_new = Variable(size(B̃))
        objective = # TODO: see (https://jump.dev/Convex.jl/stable/operations/) and Table 1 of EPCA paper
        problem = minimize(objective)
        solve!(problem, SCS.Optimizer; silent_solver=true)
        B̃ = problem.optval
        
        # find U and fix B̃
        

        # debugging
        println(poisson_loss(B, U, B̃))
    end
    return (U, B̃)
end