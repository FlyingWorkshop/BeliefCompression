using CompressedBeliefMDPs

using POMDPModels
using POMDPTools
using POMDPs

using NearestNeighbors, StaticArrays
using LocalFunctionApproximation
using LocalApproximationValueIteration

pomdp = TigerPOMDP()

# sample beliefs
sampler = DiscreteRandomSampler(pomdp)
B = sample(sampler, pomdp; n_samples=20)

# compress beliefs
n_components = 1
compressor = PCA(n_components)
fit!(compressor, B)
B̃ = compress(compressor, B)

# make function approximator
data = [SVector(row...) for row in eachrow(B̃)]
tree = KDTree(data)
k = 1  # k-nearest-neighbors
func_approx = LocalNNFunctionApproximator(tree, data, k)

# make solver
solver = LocalApproximationValueIterationSolver(func_approx, verbose=true, max_iterations=1000, is_mdp_generative=true, n_generative_samples=10)

# make compressed belief MDP
updater = DiscreteUpdater(pomdp)
mdp = CompressedBeliefMDP(pomdp, updater, compressor)

# solve
policy = solve(solver, mdp)