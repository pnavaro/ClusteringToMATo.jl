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
    
    return compute_persistence(points, f, subsets, τ )

end

"""
$(SIGNATURES)

- `k` : number of nearest neighbors to create the graph
- `q` : regularity parameter for the approximation of the density function
"""
function tomato(points::Matrix{Float64}, graph, k, q, τ)

    @assert graph in (1,2) "The variable `graph` should be 1 or 2"

    dim, n  = size(points)
    kdtree = KDTree(points)
    idxs, dists = knn(kdtree, points, q)

    f = density_function(dists, dim, q)

    if graph == 1
        subsets, dists = knn(kdtree, points, k)
    elseif graph == 2
        subsets = inrange(kdtree, points, k)
    end

    return compute_persistence(points, f, subsets, τ)

end
