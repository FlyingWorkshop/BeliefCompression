using Symbolics
using SymbolicUtils
using Optim


@syms θ

# G(θ) is a convex function
# G = log(1 + exp(θ))  # Bernoulli
G = exp(θ)

# g(θ) = G'(θ)
Dθ = Differential(θ)
g = expand_derivatives(Dθ(G))

