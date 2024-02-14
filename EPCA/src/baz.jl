using Optim
using Infiltrator

ϵ = 0.001

struct ExponentialFamilyPCA
    G
    g
    F
    f
    Bregman
end


function PoissonPCA()
    @. begin
        G(θ) = exp(θ)
        g(θ) = exp(θ)
        F(x) = x * log(x) - x
        f(x) = log(x)
        Bregman(p, q) = p * log((p + ϵ) / (q + ϵ)) + q - p  # with additive smoothing
    end
    return ExponentialFamilyPCA(G, g, F, f, Bregman)
end
    
function BernoulliPCA()
    @. begin
        G(θ) = log(1 + exp(θ))
        g(θ) = exp(θ) / (1 + exp(θ))
        F(x) = x * log(x) + (1 - x) * log(1 - x)
        f(x) = log(x / (1 - x))
        # NOTE: we only consider when p and q are belief distribution, so 1 - q + ϵ is positive (resp. for p)
        # TODO: fact check above statement
        Bregman(p, q) = p * log((p + ϵ) / (q + ϵ)) + (1 - p) * log((1 - p + ϵ) / (1 - q + ϵ))  # with additive smoothing
    end
    return ExponentialFamilyPCA(G, g, F, f, Bregman)
end


struct Compression  # TODO: Note sure if I need this
    A
    V
end


function Compression(X::Matrix, l::Int, epca::ExponentialFamilyPCA, maxiter::Int)
    """
    n = # belief samples
    d = # states
    l = # components
    # NOTE: only g and Bregman are actually used for EPCA
    """
    # constants
    μ0 = 0.5  # any value in the range of epca.g; # TODO: move this elsewhere (like into arguments)

    n, d = size(X)
    # Â = zeros(n, l)
    # V̂ = zeros(l, d)
    Â = rand(n, l)
    V̂ = rand(l, d)

    L(A, V) = sum(epca.Bregman(X, epca.g(A * V)) + ϵ * epca.Bregman(μ0, epca.g(A * V)))
    # L(A, V) = sum(epca.Bregman(X, epca.g(A * V)))


    for _ in 1:maxiter
        println("Loss: ", L(Â, V̂))
        # println("A: ", Â)
        # println("V: ", V̂)
        # println()
        # TODO: constrain optimizer search box to be between 0 and 1 (TODO: ask Mykel if this is appropriate)
        Â = Optim.minimizer(optimize(A->L(A, V̂), Â))  # optimize Â and fix V̂
        V̂ = Optim.minimizer(optimize(V->L(Â, V), V̂))  # optimize V̂ and fix Â
    end
    println("L1 Distance:", sum(X .- epca.g(Â * V̂)))
    return Compression(Â, V̂)
end


function SlowCompression(X::Matrix, l::Int, epca::ExponentialFamilyPCA, maxiter::Int)
    n, d = size(X)
    A = zeros(n, l)
    V = zeros(l, d)

    for n in 1:N
        for c in 1:l
            # Optimize the c'th component with other components fixed
            v_c = rand(d)
            s(i, j) = sum([k == c ? 0 : A[i, k] * V[k, j] for k in 1:c])
            for t in 1:maxiter
                for i in 1:n
                    A[i, c] = Optim.minimizer(optimize(a->sum([epca.Bregman(X[i, j], epca.g(a * v_c[j] + s(i, j)))  for j in 1:d]), A[i, c]))
                    # TODO: do v
                end
            end
        end
    end

end

