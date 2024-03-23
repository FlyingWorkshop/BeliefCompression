using Revise

using CompressedBeliefMDPs

using POMDPs
using POMDPModels
using POMDPTools

using MCTS

# TODO: test w/ Kalman filters 

pomdp = TMaze(6, 0.99)
# pomdp = TigerPOMDP()
# pomdp = BabyPOMDP()

compressor = KernelPCACompressor(2)
explorer = RandomPolicy(pomdp)
updater = DiscreteUpdater(pomdp)
base_solver = MCTSSolver(n_iterations=50, depth=20, exploration_constant=5.0)
n = 10
solver = CompressedBeliefSolver(explorer, updater, compressor, base_solver; n=n)
approx_policy = solve(solver, pomdp)
s = initialstate(pomdp)
v = value(approx_policy, s)  # returns the approximately optimal value for state s
a = action(approx_policy, s) # returns the approximately optimal action for state s