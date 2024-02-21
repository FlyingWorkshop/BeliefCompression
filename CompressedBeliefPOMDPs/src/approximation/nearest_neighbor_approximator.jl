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

function weight(approximator::SingleNearestNeighbor, points)
    _, dists = nn(approximator.tree, points')
    min_dist = minimum(dists)
    min_count = count(x -> x == min_dist, dists)
    w = [(d == min_dist) ? (1 / min_count) : 0 for d in dists]
    return w
end