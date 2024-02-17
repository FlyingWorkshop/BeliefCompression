function PoissonPCA(l; maxiter::Int=50, ϵ::Real=0.01, μ0::Real=0)
    @. begin
        G(θ) = exp(θ)
        g(θ) = exp(θ)
        F(x) = x * log(x) - x
        f(x) = log(x)
        Bregman(p, q) = p * log((p + ϵ) / (q + ϵ)) + q - p  # with additive smoothing
    end
    epca = EPCA(l, μ0; maxiter=maxiter, ϵ=ϵ)
    # TODO: eventually replace this w/ symbolic diff
    epca.G = G
    epca.g = g
    epca.F = F
    epca.f = f
    epca.Bregman = Bregman
    return epca
end
