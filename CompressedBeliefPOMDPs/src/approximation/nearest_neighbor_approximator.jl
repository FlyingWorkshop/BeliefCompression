using NearestNeighbors
using Parameters

@with_kw mutable struct SingleNearestNeighbor <: Approximator 
    data = nothing
    metric = Euclidean
    tree = nothing
end

# TODO: get this working somehow
# function SingleNearestNeighbor(metric=Euclidean)
#     approximator = SingleNearestNeighbor()
#     approximator.metric = metric
#     return approximator
# end

function fit!(approximator::SingleNearestNeighbor, data)
    approximator.data = data
    approximator.tree = BruteTree(data')
end

function approximate(approximator::SingleNearestNeighbor, points)
    idxs, dists = nn(approximator.tree, points')
    return approximator.data[idxs, :]
end

function weight(approximator::SingleNearestNeighbor, data)