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
        D = diag(3)  # TODO: fix this
        D_inv = D

        # recompute each column of B̃
        B̃_new = zeros(size(B))
        for (j, B̃j) in enumerate(eachrow(B̃))
            # U' * D[j] 
            B̃_new[j] = 0
        end
        # recompute each row of U
    end
    return nothing
end

end