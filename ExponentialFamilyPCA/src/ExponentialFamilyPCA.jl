module ExponentialFamilyPCA

using CompressedBeliefPOMDPs

mutable struct EPCA <: CompressedBeliefPOMDPs.Compressor
    G
    g
    U
end

CompressedBeliefPOMDPs.decompress(epca::EPCA, B̃) = epca.g(A * B̃)


# struct EPCA <: CompressedBeliefPOMDPs.Compressor
#     # TODO: should I store the compressed data as a field?
#     A::Matrix 
#     V::Matrix
#     g
#     n_components::Int
# end

# function CompressedBeliefPOMDPs.compress(::Compressor, data::Matrix)  # include optional kwargs for compressor 
#     compressor, compressed_data = Compressor(data)  # include kwargs
#     return (compressor, compressed_data)
# end

# function CompressedBeliefPOMDPs.decompress(compressor::EPCA, compressed_data:Matrix)
#     return compressor.g(A * V)
# end

# function EPCA(data::Matrix)
#     return nothing
# end

# # function CompressedBeliefPOMDPs.compress(::EPCA)

# greet() = print("Hello World!")

end # module ExponentialFamilyPCA
