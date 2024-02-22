using Pkg
Pkg.activate("CompressedBeliefPOMDPs")
using CompressedBeliefPOMDPs
using ExpFamilyPCA

using POMDPModels
using POMDPTools
using POMDPs

using NearestNeighbors, StaticArrays
using LocalFunctionApproximation


# pomdp = TMaze()
pomdp = BabyPOMDP() 

# sample beliefs
sampler = DiscreteRandomSampler(pomdp, n_samples=20)  # TODO: change this to a epsilong greedy
B = sample(sampler, pomdp)

# compress beliefs
compressor = PoissonPCA(2)
fit!(compressor, B)
B̃ = compress(compressor, B)

# make function approximator
data = [SVector(row...) for row in eachrow(B̃)]
tree = KDTree(data)
k = 1  # k-nearest-neighbors
func_approx = LocalNNFunctionApproximator(tree, data, k)

# make approx solver
approx_solver = LocalApproximationValueIterationSolver(func_approx, verbose=true, max_iterations=1000, is_mdp_generative=true)

# make compressed belief MDP
updater = DiscreteUpdater(pomdp)
comp_bmdp = CompressedBeliefMDP(pomdp, compressor, updater)

# solve
approx_policy = solve(approx_solver, comp_bmdp)