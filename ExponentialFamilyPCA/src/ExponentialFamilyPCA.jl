module ExponentialFamilyPCA

using CompressedBeliefPOMDPs

mutable struct EPCA <: CompressedBeliefPOMDPs.Compressor
    maxiter::Int = 10
    n::Int
    l::Int
    d::Int

    A::Matrix
    V::Matrix  # basis matrix

    ϵ::Float = 0.01  # smoothing parameter
    μ0::Real  # must be in the range of g

    # functions
    G
    g
    F
    f
    Bregman

    A::Matrix
    V::Matrix
end

"""
    EPCA(G)

Return the EPCA induced by a convex function G.
"""
function EPCA(G)
    return nothing
end


function CompressedBeliefPOMDPs.fit!(epca::EPCA, X::Matrix)
    epca.n, epca.d = size(X)
    epca.A = rand(epca.n, epca.l)
    epca.V = rand(epca.l, epca.d)

    L(A, V) = sum(epca.Bregman(X, epca.g(A * V)) + epca.ϵ * epca.Bregman(epca.μ0, epca.g(A * V)))

    for _ in 1:maxiter
        println("Loss: ", L(Â, V̂))
        # println("A: ", Â)
        # println("V: ", V̂)
        # println()
        epca.A = Optim.minimizer(optimize(A->L(A, epca.V), epca.A))
        epca.V = Optim.minimizer(optimize(V->L(epca.A, V), epca.V))
    end
end

# CompressedBeliefPOMDPs.compress(epca::EPCA, data::Matrix) = 
CompressedBeliefPOMDPs.decompress(epca::EPCA, compressed::Matrix) = epca.g(epca.A * B̃)

end # module ExponentialFamilyPCA
