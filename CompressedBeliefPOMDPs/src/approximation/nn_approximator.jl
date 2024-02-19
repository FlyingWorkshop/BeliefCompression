# using Interpolations
# using Parameters
# using .approximator: Approximator, fit!, approximate


# mutable struct NearestNeighborApproximator <: Approximator
#     resolution
# end

# function fit!(approximator::NearestNeighborApproximator, data; resolution=10)
#     min_ = minimum(data, dims=2)
#     max_ = maximum(data, dims=2)
#     nodes = Tuple(range(start=i, stop=j, length=approximator.resolution) for (i, j) in zip(min_, max_))
#     grid = hcat(nodes...)
# end


