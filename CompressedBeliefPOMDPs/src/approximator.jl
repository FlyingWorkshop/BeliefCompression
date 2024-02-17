using NearestNeighbors


abstract type Approximator end
struct SingleNearestNeighbor <: Approximator end


function approximate(::SingleNearestNeighbor, data, points)
    tree = BruteTree(data')
    idxs, _ = nn(tree, points')
    return data[idxs, :]
end