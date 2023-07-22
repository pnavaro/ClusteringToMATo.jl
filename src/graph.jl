abstract type AbstractNeighborhoodGraph end

export compute_graph

export BallGraph

"""
$(TYPEDEF)
"""
struct BallGraph <: AbstractNeighborhoodGraph
    δ :: Float64
    BallGraph(δ) = new(δ)
end

function compute_graph( graph :: BallGraph, points )

    balltree = BallTree(points)
    subsets = inrange(balltree, points, graph.δ, true)
    return subsets

end

export KNNGraph

"""
$(TYPEDEF)
"""
struct KNNGraph <: AbstractNeighborhoodGraph
    k :: Int
    KNNGraph(k::Int) = new(k)
end

function compute_graph( graph :: KNNGraph, points )

    kdtree = KDTree(points)
    subsets, dists = knn(kdtree, points, graph.k)
    return subsets

end
