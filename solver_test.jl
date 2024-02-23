using CompressedBeliefMDPs
using ExpFamilyPCA

using POMDPModels
using POMDPTools
using POMDPs

using NearestNeighbors, StaticArrays
using LocalFunctionApproximation
using LocalApproximationValueIteration


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

# make solver
solver = LocalApproximationValueIterationSolver(func_approx, verbose=true, max_iterations=1000, is_mdp_generative=true, n_generative_samples=10)

# make compressed belief MDP
updater = DiscreteUpdater(pomdp)
mdp = CompressedBeliefMDP(pomdp, updater, compressor)

# solve
policy = solve(solver, mdp)