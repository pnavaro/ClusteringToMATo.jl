module ClusteringToMATo

using DataStructures
using Distances
using DocStringExtensions
using NearestNeighbors

export tomato, density_function


"""
$(SIGNATURES)
"""
function ball_density(points, δ)

    n = size(points, 2)
    btree = BallTree(points)
    n_neighbors = inrangecount(btree, points, δ)

    return - (n_neighbors .+ 1) ./ n

end


"""
$(SIGNATURES)
"""
function dtm(points, k::Int)

    d, n  = size(points)
    kdtree = KDTree(points)
    idxs, dists = knn(kdtree, points, k)
    
    f = zeros(n)
    for i = 1:n
        f[i] = sqrt(k / sum(dists[i].^2))
    end
    f

end

"""
$(SIGNATURES)
"""
function gaussian_nn(points, k::Int, h)

    d, n  = size(points)
    kdtree = KDTree(points)
    idxs, dists = knn(kdtree, points, k)
    
    f = zeros(n)
    for i = 1:n
        f[i] = - sum(exp.(dists[i]*(-0.5)/h))
    end
    f

end

"""
$(SIGNATURES)
"""
function gaussian_mu(points, δ, h)

    d, n  = size(points)
    btree = BallTree(points)
    idxs = inrange(btree, points, δ)
    dists = pairwise(Euclidean(), points, dims=2)
    f = zeros(n)
    for i = 1:n
        f[i] = - sum(exp(dists[i,j]*(-0.5)/h) for j in idxs[i])
    end
    f

end


"""
$(SIGNATURES)
"""
function density_function(points::Matrix{Float64}, k::Int)

    d, n  = size(points)
    kdtree = KDTree(points)
    idxs, dists = knn(kdtree, points, k)
    density_function(dists, d, k)

end

"""
$(SIGNATURES)

density function approximation

- `q` regularity parameter

"""
function density_function( dists::Vector{Vector{Float64}}, d::Int, k::Int)

    n = length(dists)
    f = zeros(n)
    
    if d == 2
        for i = 1:n
            f[i] = k * (k + 1) / (2π * n * sum(dists[i] .^ 2))
        end
    elseif d == 3
        for i = 1:n
            f[i] = k * (k + 1) / (2π * n * (4 / 3) * sum(dists[i] .^ 3))
        end
    elseif d == 1
        for i = 1:n
            f[i] = k * (k + 1) / (2n * sum(dists[i]))
        end
    end

    return f

end

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
"""
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

end
