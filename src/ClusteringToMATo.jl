module ClusteringToMATo

using DataStructures
using NearestNeighbors

export data2clust, density_function

function density_function(points::Matrix{Float64}, q::Int)

    d, n  = size(points)
    kdtree = KDTree(points)
    idxs, dists = knn(kdtree, points, q)
    density_function(dists, d, q)

end

"""
    density_function( dists, d, q)

density function approximation

- `q` regularity parameter

"""
function density_function( dists::Vector{Vector{Float64}}, d::Int, q::Int)

    n = length(dists)
    f = zeros(n)
    
    if d == 2
        for i = 1:n
            f[i] = q * (q + 1) / (2π * n * sum(dists[i] .^ 2))
        end
    elseif d == 3
        for i = 1:n
            f[i] = q * (q + 1) / (2π * n * (4 / 3) * sum(dists[i] .^ 3))
        end
    elseif d == 1
        for i = 1:n
            f[i] = q * (q + 1) / (2n * sum(dists[i]))
        end
    end

    return f

end

function data2clust(points::Matrix{Float64}; graph = 1, k = 4, q = 4, τ = 0.01)

    data2clust(points::Matrix{Float64}, graph, k, q, τ)

end

function data2clust(points::Matrix{Float64}, f::Vector{Float64}, radius, τ)
    
    @assert size(points,2) == length(f) "number of points and density are not compatible"
    balltree = BallTree(points)
    subsets = inrange(balltree, points, radius, true)
    
    return compute_persistence(points, f, subsets, τ )

end



function compute_persistence(points, f, subsets, τ)
    
    d, n = size(points)

    intervals = Dict{Int,Tuple{Float64,Float64}}()
    v = sortperm(f, rev = true) # sort vertices using f
    f .= f[v] # sort f
    vertices_corr_inv = Dict(zip(v, 1:n)) #indexes of vertices in f
    G = [[vertices_corr_inv[i] for i in subset] for subset in subsets[v]]
    𝒰 = IntDisjointSets(n)
    for i = eachindex(v)
        𝒩 = [j for j in G[i] if j < i]
        if length(𝒩) == 0
            intervals[i] = (f[i], Inf)
        else
            g = 𝒩[argmax(view(f, 𝒩))] # approximate gradient at vertex i
            eᵢ = find_root!(𝒰, g) # r(eᵢ)
            union!(𝒰, eᵢ, i) # Attach vertex i to the entry eᵢ
            for j in 𝒩
                e = find_root!(𝒰, j) # r(e)
                if e != eᵢ && min(f[e], f[eᵢ]) <= f[i] + τ # merge
                    if f[e] < f[eᵢ]
                        union!(𝒰, eᵢ, e)
                        intervals[j] = (f[e], f[eᵢ])
                    else
                        union!(𝒰, e, eᵢ)
                        intervals[i] = (f[eᵢ], f[e])
                    end 
                    eᵢ = find_root!(𝒰, e)   
                end
            end
        end
    end
    # the collection of entries e of 𝒰 such that f(r(e)) ≥ τ
    s = Set{Int}([])
    for i = 1:n
        g = find_root!(𝒰, i) #  r(e)
        if f[g] >= τ 
           push!(s, g)
        end
    end

    labels = zeros(Int, n)
    for (c,j) in enumerate(s), i in 1:n
        if in_same_set(𝒰, j, i)
            labels[v[i]] = c
        end
    end

    return labels, intervals

end

"""
    data2clust(points, graph, k, q, τ)

- `k` : number of nearest neighbors to create the graph
- `q` : regularity parameter for the approximation of the density function
"""
function data2clust(points::Matrix{Float64}, graph, k, q, τ)

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

# using LinearAlgebra
# 
# function distance_to_density(points, k)
#     n = size(points, 2)
#     balltree = BallTree(points)
#     idxs = inrange(balltree, points, radius, true)
#     f = zeros(n)
# 
#     for i = 1:n
#         dists = [norm(points[:,i] - points[:,j], 2) for j in idxs[i]]
#         f[i] = sqrt(k / sum(dists.^2))
#     end
#     return f
# end
# 
# function gaussian_nn(points, k, h)
# 
#     kdtree = KDTree(points)
#     idxs, dists = knn(kdtree, points, k)
# 
#     return - sum(exp.(dists .* (-0.5)/h))
# end

end
