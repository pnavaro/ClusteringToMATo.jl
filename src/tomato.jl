export tomato

"""
$(SIGNATURES)

`points` is a matrix of size nd × np where nd is the dimensionality and np is the number of points
"""
function tomato(points::Matrix{Float64}; graph = 1, k = 4, q = 4, τ = 0.01)

    tomato(points::Matrix{Float64}, graph, k, q, τ)

end

"""
$(SIGNATURES)
"""
function tomato(points::Matrix{Float64}, f::Vector{Float64}, δ, τ)
    
    @assert size(points,2) == length(f) "number of points and density are not compatible"
    balltree = BallTree(points)
    subsets = inrange(balltree, points, δ, true)
    
    return compute_persistence( f, subsets, τ )

end

"""
$(SIGNATURES)

- `k` : number of nearest neighbors to create the graph
- `q` : regularity parameter for the approximation of the density function
"""
function tomato(points::Matrix{Float64}, graph, k, q, τ)

    @assert graph in (1,2) "The variable `graph` should be 1 or 2"

    f = compute_density(DensityKNN(q), points)

    if graph == 1
        subsets = compute_graph(KNNGraph(k), points)
    elseif graph == 2
        subsets = compute_graph(BallGraph(k), points)
    end

    return compute_persistence(f, subsets, τ)

end

function tomato(points::Matrix{Float64}, 
                graph::AbstractNeighborhoodGraph,
                density::AbstractDensityComputation, τ)

    f = compute_density(density, points)

    g = compute_graph(graph, points)

    return compute_persistence(f, g, τ)

end

function tomato(points::Matrix{Float64}, g::Vector{Vector{Int}}, f::Vector{Float64}, τ)

    return compute_persistence(f, g, τ)

end
