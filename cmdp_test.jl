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
compressor = PoissonPCA(2)
fit!(compressor, B)

updater = DiscreteUpdater(pomdp)
comp_bmdp = CompressedBeliefMDP(pomdp, updater, compressor)
@show comp_bmdp