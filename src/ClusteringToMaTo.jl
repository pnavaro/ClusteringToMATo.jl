module ClusteringToMaTo

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
        idxs, dists = knn(kdtree, points, k)
    elseif graph == 2
        idxs = inrange(kdtree, points, k)
    end

    v = sortperm(f, rev = true)
    f .= f[v]
    vertices_corr_inv = Dict(zip(v, 1:n))
    clusters = [[vertices_corr_inv[i] for i in subset] for subset in idxs[v]]
    u = IntDisjointSets(n)
    for i = eachindex(v)
        nGi = [j for j in clusters[i] if j < i]
        if length(nGi) == 0
            continue
        else
            g = nGi[argmax(view(f, nGi))]
            ei = find_root!(u, g)
            union!(u, ei, i)
            for j in nGi
                e = find_root!(u, j)
                if e != ei && min(f[e], f[ei]) < f[i] + τ
                    if f[e] < f[ei]
                        union!(u, ei, e)
                    else
                        union!(u, e, ei)
                    end
                    e2 = find_root!(u, e)
                    ei = e2
                end
            end
        end
    end

    s = Int[]
    for i = 1:n
        g = find_root!(u, i)
        if f[g] >= τ && !(g in s)
           push!(s, g)
        end
    end
    labels = zeros(Int, n)
    for j = eachindex(s), i in 1:n
        if in_same_set(u, s[j], i)
            labels[v[i]] = j
        end
    end

    return labels

end

end
