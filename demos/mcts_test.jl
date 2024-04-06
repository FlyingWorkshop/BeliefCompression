using Revise

using POMDPs, POMDPTools, POMDPModels
using RockSample
using ParticleFilters
using MCTS
using Random

using CompressedBeliefMDPs


Random.seed!(5)

pomdp = RockSamplePOMDP(rocks_positions=[(2,3), (4,4), (4,2)], 
                        sensor_efficiency=20.0,
                        discount_factor=0.95, 
                        good_rock_reward = 20.0)

updater = BootstrapFilter(pomdp, 1000)
bmdp = GenerativeBeliefMDP(pomdp, updater)


solver1 = DPWSolver()
planner1 = solve(solver1, bmdp)

# It doesn't matter what compressor I use or what dimension I compress to
solver2 = CompressedBeliefSolver(
    pomdp,
    solver1;
    updater=updater,
    compressor=PCACompressor(1),
    sampler=PolicySampler(pomdp; policy=RandomPolicy(pomdp; updater=updater), updater=updater)
)
planner2 = solve(solver2, pomdp)

rs = RolloutSimulator(max_steps=100)
r1 = simulate(rs, bmdp, planner1)
r2 = simulate(rs, bmdp, planner2)
@show r1
@show r2
