using POMDPs

using POMDPModelTools: GenerativeBeliefMDP


struct CompressedBeliefMDP{P<:POMDP, C<:Compressor, U<:Updater, B, A} <: MDP{B, A}
    bmdp::GenerativeBeliefMDP
    compressor::Compressor
end

CompressedBeliefMDP(p::POMDP, c::Compressor, up::Updater) = CompressedBeliefMDP(GenerativeBeliefMDP(p, up), c)


function encode(::Type{V}, c::Compressor, b) where V<:AbstractArray
    b = convert(V, b)
    b̃ = compress(c, b)
    return b̃
end

function decode(::Type{S}, c::Compressor, b̃::V) where {S, V<:AbstractArray}
    b = decompress(c, b̃)
    b = convert(S, b)
    return b
end

function POMDPs.gen(m::CompressedBeliefMDP, b̃::V, a, rng::AbstractRNG) where V<:AbstractArray
    b = convert(statetype(m.bmdp), decompress(m.compressor, b̃))
    bp, r = @gen(:sp, :o, :r)(m.bmdp, b, a, rng)
    b̃p = compress(m.compressor, convert(V, bp))
    return (sp=b̃p, r=r)
end

actions(m::CompressedBeliefMDP, b̃) = actions(m.bmdp, decompress(m.compressor, b̃))
actions(m::CompressedBeliefMDP) = actions(m.bmdp)

isterminal(m::CompressedBeliefMDP, b̃) = isterminal(m.bmdp, decompress(m.decompress, b̃))

discount(m::CompressedBeliefMDP) = discount(m.bmdp)

# initialstate(m::CompressedBeliefPOMDP) = nothing


# convenience conversions
convert(::Type{V}, b::DiscreteBelief) where V<:AbstractArray = V(b.b)
convert(::Type{DiscreteBelief{P, S}}, b::V) where V<:AbstractArray = DiscreteBelief(P, b)
