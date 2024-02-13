using POMDPs
using Optim
using LinearAlgebra

using Infiltrator

"""Compression"""
DEFAULT_MAXITER = 5  # TODO: change this to 50 or so for deployment

struct Compression
    # TODO: rename compression struct to EPCA or something along those lines
    U  # basis matrix
    V  # compressed beliefs
end

function Compression(objective, B::Matrix, n_components::Int, maxiter::Int)
    """
    The objective function is the Bregman divergence, a binary function of U and V.
    """
    n_states, n_samples = size(B)

    # initialize parameters
    U = rand(n_states, n_components)
    V = rand(n_components, n_samples)

    for _ in 1:maxiter
        V = Optim.minimizer(optimize(V̂->objective(U, V̂), V))  # optimize V and fix U
        U = Optim.minimizer(optimize(Û->objective(Û, V), U))  # optimize U and fix V
    end

    return Compression(U, V)
end

function poisson_loss(U, V)
    B = exp.(U * V)  # TODO: check w/ Mykel that this is correct; see Eq. (4) in short paper + Eqs. (6, 8) in long paper
    loss = exp.(U * V) .- B ⋅ (U * V)
    return sum(loss)  # TODO: check if this sum is over all elements
end


function PoissonPCA(B::Matrix, n_components::Int, maxiter::Int)
    return Compression(poisson_loss, B, n_components, maxiter)
end
