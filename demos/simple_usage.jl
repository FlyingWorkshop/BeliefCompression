using POMDPs
using POMDPModels
using CompressedBeliefMDPs

pomdp = TigerPOMDP()
sampler = DiscreteRandomSampler(pomdp)
compressor = PCACompressor(2)
solver = CompressedSolver(pomdp, sampler, compressor)
policy = POMDPs.solve(solver, pomdp)