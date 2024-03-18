using BasicPOMCP
using POMDPs
using POMDPTools
using POMDPModels

pomdp = BabyPOMDP()
solver = POMCPSolver()
planner = solve(solver, pomdp)
r = value(planner, initialstate(pomdp))
