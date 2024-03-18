using Infiltrator

using POMDPs
using POMDPTools
using POMDPModels
using NearestNeighbors
using StaticArrays
using LocalFunctionApproximation
using LocalApproximationValueIteration

using Plots

# TODO: this redundancy is due to some quirks of POMDPLinter.jl and multiple dispatch
POMDPs.convert_s(::Type{V}, s::Number, problem::GenerativeBeliefMDP) where V<:AbstractArray = convert_s(V, s, problem.pomdp)
POMDPs.convert_s(::Type{V}, s, problem::GenerativeBeliefMDP) where V<:AbstractArray = convert_s(V, s, problem.pomdp)
POMDPs.convert_s(::Type{S}, v::V, problem::GenerativeBeliefMDP) where {S,V<:AbstractArray} = convert_s(S, v, problem.pomdp)

function POMDPs.convert_s(::Type{<:AbstractArray}, b::DiscreteBelief, ::BabyPOMDP)
    b.b
end

function POMDPs.convert_s(::Type{<:DiscreteBelief}, v, m::BabyPOMDP)
    @assert length(v) == 1
    p = v[1]
    DiscreteBelief(m, [p, 1 - p])
end

POMDPs.actionindex(m::GenerativeBeliefMDP, a) = actionindex(m.pomdp, a)  # TODO: figure out if can just wrap m.bmdp

pomdp = BabyPOMDP()
mdp = GenerativeBeliefMDP(pomdp, DiscreteUpdater(pomdp))
data = [SVector(0.), SVector(1.)]
tree = KDTree(data)
interp = LocalNNFunctionApproximator(tree, data, 2)
approx_solver = LocalApproximationValueIterationSolver(interp, verbose=true, max_iterations=1000, is_mdp_generative=true, n_generative_samples=10)
approx_policy = solve(approx_solver, mdp)


# plot
x = LinRange(0, 1, 5)
y = map(p->value(approx_policy, p), x)
plot(x, y)