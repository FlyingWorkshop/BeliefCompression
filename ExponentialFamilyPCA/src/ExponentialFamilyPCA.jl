module ExponentialFamilyPCA

using Optim
using CompressedBeliefPOMDPs


mutable struct EPCA <: CompressedBeliefPOMDPs.Compressor
    n::Int  # number of samples
    d::Int  # size of each sample
    l::Int  # number of components
    A::Matrix  # n x l matrix
    V::Matrix  # l x d basis matrix

    G  # convex function that induces g, F, f, and Bregman
    g  # g(θ) = G'(θ)
    F  # F(g(θ)) + G(θ) = g(θ)θ
    f  # f(x) = F'(x)
    Bregman  # generalized Bregman divergence induced by F

    μ0::Real  # for numerical stability; must be in the range of g
    maxiter::Int
    ϵ::Real  # for additive smoothing

    EPCA() = new()
end


# TODO: implement this with Symbolics of SymEnginer
# """
#     EPCA(G)

# Return the EPCA induced by a convex function G.
# """
# function EPCA(G)
#     return nothing
# end


function EPCA(l::Int, μ0::Real; maxiter::Int=50, ϵ::Float64=0.01)
    epca = EPCA()
    epca.l = l
    epca.μ0 = μ0
    epca.maxiter = maxiter
    epca.ϵ = ϵ
    return epca
end


function CompressedBeliefPOMDPs.fit!(epca::EPCA, X::Matrix)
    @assert epca.l > 0
    epca.n, epca.d = size(X)
    epca.A = rand(epca.n, epca.l)
    epca.V = rand(epca.l, epca.d)

    L(A, V) = sum(epca.Bregman(X, epca.g(A * V)) + epca.ϵ * epca.Bregman(epca.μ0, epca.g(A * V)))

    for _ in 1:epca.maxiter
        println("Loss: ", L(epca.A, epca.V))
        # println("A: ", Â)
        # println("V: ", V̂)
        # println()
        epca.A = Optim.minimizer(optimize(A->L(A, epca.V), epca.A))
        epca.V = Optim.minimizer(optimize(V->L(epca.A, V), epca.V))
    end
end

# CompressedBeliefPOMDPs.compress(epca::EPCA, data::Matrix) = 
CompressedBeliefPOMDPs.decompress(epca::EPCA, compressed::Matrix) = epca.g(epca.A * B̃)

export
    PoissonPCA
include("poisson.jl")


end # module ExponentialFamilyPCA
