using Revise

using POMDPs, POMDPModels, POMDPTools
using CompressedBeliefMDPs

pomdp = TMaze(60, 0.9)
solver = CompressedBeliefSolver(
    pomdp;
    compressor=VAECompressor(123, 6; hidden_dim=10, verbose=true, epochs=2),
    sampler=PolicySampler(pomdp, n=500),
    verbose=true, 
    max_iterations=1000, 
    n_generative_samples=30,
    k=2
)
policy = solve(solver, pomdp)
rs = RolloutSimulator(max_steps=50)
r = simulate(rs, pomdp, policy)
