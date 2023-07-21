module ClusteringToMATo

using DataStructures
using Distances
using DocStringExtensions
using NearestNeighbors

export tomato, density_function

include("density.jl")
include("graph.jl")
include("persistence.jl")
include("tomato.jl")

end
