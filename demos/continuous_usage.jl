using Revise

using POMDPs, POMDPModels, POMDPTools
using ParticleFilters
using MCTS
using CompressedBeliefMDPs

pomdp = LightDark1D()
pomdp.movement_cost = 1
base_solver = MCTSSolver(n_iterations=10, depth=50, exploration_constant=5.0)
updater = BootstrapFilter(pomdp, 100)
solver = CompressedBeliefSolver(
    pomdp,
    base_solver;
    updater=updater,
    sampler=PolicySampler(pomdp; updater=updater)
)
policy = solve(solver, pomdp)
rs = RolloutSimulator(max_steps=50)
r = simulate(rs, pomdp, policy)
@show r
