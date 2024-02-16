using NearestNeighbors


abstract type Approximation end
struct SingleNearestNeighbor <: Approximation end


function approximate(::SingleNearestNeighbor, data, points)
    tree = BruteTree(data')
    idxs, _ = nn(tree, points')
    return data[idxs, :]
end