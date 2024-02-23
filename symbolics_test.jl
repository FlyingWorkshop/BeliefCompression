using Symbolics
using InverseFunctions
using Optim


@variables θ

# G(θ) is a convex function
G = log(1 + exp(θ))

# g(θ) = G'(θ)
Dθ = Differential(θ)
g = expand_derivatives(Dθ(G))


function f(x)
    expr = Symbolics.toexpr(g)
    θ = x
    eval(expr)

