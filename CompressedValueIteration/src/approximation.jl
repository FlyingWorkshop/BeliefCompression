abstract type Approximation end
struct SingleNearestNeighbor <: Approximation end

function approximate(::SingleNearestNeighbor, A, B)
    return nothing
end