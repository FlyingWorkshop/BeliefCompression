using POMDPs, POMDPTools

"""Compression"""
abstract type Compression end
mutable struct PoissonPCA <: Compression
    U
end

function PoissonPCA(belief_points::Vector{Vector{Float64}})
    U = nothing
    return PoissonPCA(U)
end

"""Approximation"""
abstract type Approximation end
mutable struct NearestNeighborBeliefSample <: Approximation
    belief_samples::Vector{Vector{Float64}}
end

"""Policies"""
mutable struct PoissonPCANearestNeighborsPolicy <: POMPs.Policy
    compression::PoissonPCA
    n_components::Int
    policy_mapping  # maybe some mapping for compressed beliefs
end

# TODO: make a function that generates policieds given different compressions
function generate_policy(comp::PoissonPCA, n_components::Int, approx::NearestNeighborBeliefSamples, pomdp::POMDP)
    return PoissonPCAPoilcy(comp, dims, policy_mapping)
end

"""Solvers"""
mutable struct CompressedSolver <: POMDPs.Solver
    pomdp::POMDP.POMDP
    compression::Compression
    n_components::Int
    approximation_strategy::Approximation
end 