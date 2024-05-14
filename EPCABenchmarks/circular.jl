using Revise
using CompressedBeliefMDPs
using ExpFamilyPCA

using SARSOP


pomdp = CircularCorridorPOMDP()
solver = SARSOPSolver()
policy = solve(solver, pomdp)
