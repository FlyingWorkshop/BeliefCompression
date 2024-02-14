abstract type Approximation end
mutable struct NearestNeighborBeliefSamples <: Approximation
    belief_samples
end