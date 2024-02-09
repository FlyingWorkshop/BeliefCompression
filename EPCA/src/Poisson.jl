using LinearAlgebra
using Infiltrator


function poisson_loss(B, U, B̃)
    loss = exp.(U * B̃) - B ⋅ (U * B̃)
    return sum(loss)
end

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
        # recompute each column of B̃; see Eq. (26) in Roy
        B̃_new = zeros(size(B))
        for (j, B̃j) in enumerate(eachcol(B̃))
            @infiltrate
            Dj = Diagonal(exp.(U * B̃j))
            numerator = U' * Dj * (U * B̃j + inv(Dj) * (B[:, j] - exp.(U * B̃j)))
            denominator = U' * Dj * U + regularizer
            B̃_new[:, j] = numerator / denominator
        end
        B̃ = B̃_new

        # recompute each row of U; see Eq. (27) in Roy
        U_new = zeros(size(U))
        for (i, Ui) in enumerate(eachrow(U))
            Di = Diagonal(exp.(U * B̃[:, i]))
            numerator = (Ui * B̃ + (B[i, :] - exp.(Ui * B̃)) * inv(Di)) * Di * B̃'
            denominator = B̃ * Di * B̃' + regularizer
            U_new[i, :] = numerator / denominator
        end
        U = U_new

        # debugging
        println(poisson_loss(B, U, B̃))
    end
    return (U, B̃)
end