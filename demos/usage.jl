using Revise

using CompressedBeliefMDPs

using POMDPs
using POMDPModels
using POMDPTools

using Random

Random.seed!(1)

pomdp = TMaze(200, 0.99)
pomdp = BabyPOMDP()
solver = CompressedBeliefSolver(
    pomdp;
    compressor=VAECompressor(403, 50; hidden_dim=100, verbose=true, epochs=100),
    sampler=PolicySampler(pomdp, n=1000),
    verbose=true, 
    max_iterations=100, 
    n_generative_samples=50, 
    # k=2, 
)
solver = SARSOPSolver(timeout=30)
policy = solve(solver, pomdp)
s = initialstate(pomdp)
a = action(policy, s) # returns the approximately optimal action for state s
v = value(policy, s)  # returns the approximately optimal value for state s

rs = RolloutSimulator(max_steps=50)
compressed_r = simulate(rs, pomdp, policy)
