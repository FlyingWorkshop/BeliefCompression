using Symbolics
using Optim


# PLAN: induce an EPCA compression either by providing F or by providing G

@syms θ

# G(θ) is a convex function
G = log(1 + exp(θ))  # Bernoulli
# G = exp(θ)  # Poisson


# g(θ) = G'(θ)
D = Differential(θ)
g = expand_derivatives(D(G))
expression = Symbolics.toexpr(g)
eval(:(Fg(θ) = $expression))

# Fg = g * θ - G

# function Bregman(p, q)

