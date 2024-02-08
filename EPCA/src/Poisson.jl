module Poisson

using LinearAlgebra


function poisson_loss(B, U, B̃)
    UB̃ = U * B̃
    loss = exp.(UB̃) - B ⋅ UB̃
    return sum(loss)
end

function poisson_epca(B, n_components, maxiter=50)
    """
    B̃ is a n_states x n_samples matrix -- compressed beliefs
    U is a n_states x n_components matrix -- basis
    """
    # Fix an initial estimate for B̃ and U randomly
    n_states, n_samples = size(B)
    B̃ = rand(n_states, n_samples)
    U = rand(n_states, n_components)
    for _ in 1:maxiter
        # recompute each column of B̃
        println("TODO")
        # recompute each row of U
    end
    return nothing
end

end