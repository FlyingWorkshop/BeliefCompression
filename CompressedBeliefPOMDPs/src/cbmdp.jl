using POMDPs
using POMDPModelTools: GenerativeBeliefMDP
using POMDPTools: DiscreteBelief

using Random: AbstractRNG
using LinearAlgebra

struct CompressedBeliefMDP{B, A} <: MDP{B, A}
    bdmp::GenerativeBeliefMDP
    compressor::Compressor
end

function CompressedBeliefMDP(bmdp::GenerativeBeliefMDP, compressor::Compressor)
    CompressedBeliefMDP(bmdp, compressor, statetype(bmdp), actiontype(bmdp))
end


# TODO: why no work?
# struct CompressedBeliefMDP{P<:POMDP, C<:Compressor, U<:Updater, B, A} <: MDP{B, A}
#     bmdp::GenerativeBeliefMDP
#     compressor::Compressor
# end

# TODO: why doesn't this work?
# CompressedBeliefMDP(p::P, c::C, up::U) where {P<:POMDP,C<:Compressor,U<:Updater} = CompressedBeliefMDP(GenerativeBeliefMDP(p, up), c)
# CompressedBeliefMDP(pomdp, compressor, updater) = CompressedBeliefMDP(GenerativeBeliefMDP(pomdp, updater), compressor)


function encode(m::CompressedBeliefMDP, b)
    # b = convert(AbstractArray, b)  # TODO: convert to abstract array???
    b = b.b  # TODO: make more general
    b̃ = compress(m.compressor, b)
    return b̃
end

function decode(m::CompressedBeliefMDP, b̃::V) where V<:AbstractArray
    b = decompress(m.compressor, b̃)
    normalize!(b, 1)
    # TODO: ask Mykel about this
    # b = convert(statetype(m.bmdp), b)  
    b = DiscreteBelief(m.bmdp.pomdp, b)
    return b
end

function POMDPs.gen(m::CompressedBeliefMDP, b̃::V, a, rng::AbstractRNG) where V<:AbstractArray
    b = decode(m, b̃)
    bp, r = @gen(:sp, :o, :r)(m.bmdp, b, a, rng)
    b̃p = encode(m, bp)
    return (sp=b̃p, r=r)
end

actions(m::CompressedBeliefMDP, b̃) = actions(m.bmdp, decompress(m.compressor, b̃))
actions(m::CompressedBeliefMDP) = actions(m.bmdp)

isterminal(m::CompressedBeliefMDP, b̃) = isterminal(m.bmdp, decompress(m.decompress, b̃))

discount(m::CompressedBeliefMDP) = discount(m.bmdp)

# initialstate(m::CompressedBeliefPOMDP) = nothing

# convenience conversions
# TODO: ask Mykel about this
# convert(::Type{V}, b::DiscreteBelief) where V<:AbstractArray = V(b.b)
# convert(::Type{DiscreteBelief{P, S}}, b::V) where V<:AbstractArray = DiscreteBelief(P, b)
