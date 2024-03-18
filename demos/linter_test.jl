using POMDPs
using POMDPTools
using POMDPModels
using NearestNeighbors
using StaticArrays
using LocalFunctionApproximation
using LocalApproximationValueIteration


POMDPs.convert_s(t, s, m::GenerativeBeliefMDP) = convert_s(t, s, m.pomdp)
POMDPs.convert_s(::Type{<:AbstractArray}, b::DiscreteBelief, ::BabyPOMDP) = b.b
POMDPs.convert_s(::Type{<:DiscreteBelief}, v, m::BabyPOMDP) = DiscreteBelief(m, [p, 1 - p])
POMDPs.actionindex(m::GenerativeBeliefMDP, a) = actionindex(m.pomdp, a)

pomdp = BabyPOMDP()
mdp = GenerativeBeliefMDP(pomdp, DiscreteUpdater(pomdp))
data = [SVector(0.), SVector(1.)]
tree = KDTree(data)
interp = LocalNNFunctionApproximator(tree, data, 2)
approx_solver = LocalApproximationValueIterationSolver(interp, verbose=true, max_iterations=1000, is_mdp_generative=true, n_generative_samples=10)
approx_policy = solve(approx_solver, mdp)