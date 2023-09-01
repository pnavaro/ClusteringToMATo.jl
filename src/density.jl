abstract type AbstractDensityComputation end

export BallDensity

"""
$(TYPEDEF)
"""
struct BallDensity <: AbstractDensityComputation
    δ :: Float64
    BallDensity(δ) = new(δ)
end

"""
$(SIGNATURES)
"""
function compute_density(df::BallDensity, points)

    n = size(points, 2)
    btree = BallTree(points)
    n_neighbors = inrangecount(btree, points, df.δ)

    return (n_neighbors .+ 1) ./ n

end

export DTM

"""
$(TYPEDEF)
"""
struct DTM <: AbstractDensityComputation
    k :: Int
end

export compute_density

"""
$(SIGNATURES)
"""
function compute_density(df::DTM, points)

    d, n  = size(points)
    kdtree = KDTree(points)
    idxs, dists = knn(kdtree, points, df.k)
    
    f = zeros(n)
    for i = 1:n
        f[i] = sqrt(df.k / sum(dists[i].^2))
    end
    return f

end

export GaussianNN

"""
$(TYPEDEF)
"""
struct GaussianNN <: AbstractDensityComputation
    k :: Int
    h :: Float64
end

"""
$(SIGNATURES)
"""
function compute_density(df::GaussianNN, points)

    d, n  = size(points)
    kdtree = KDTree(points)
    idxs, dists = knn(kdtree, points, df.k)
    
    f = zeros(n)
    for i = 1:n
        f[i] = sum(exp.(-d * (0.5)/df.h) for d in dists[i])
    end
    return f

end

export GaussianCutoff

"""
$(TYPEDEF)
"""
struct GaussianCutoff <: AbstractDensityComputation
    δ :: Float64
    h :: Float64
end

"""
$(SIGNATURES)
"""
function compute_density(df::GaussianCutoff, points)

    d, n  = size(points)
    btree = BallTree(points)
    idxs = inrange(btree, points, df.δ)
    dists = pairwise(Euclidean(), points, dims=2)
    f = zeros(n)
    for i = 1:n
        f[i] = sum(exp(d * (-0.5)/df.h) for d in dists[i,:])
    end
    return f

end

export KNNDensity

"""
$(TYPEDEF)
"""
struct KNNDensity  <: AbstractDensityComputation
    k :: Int
end

"""
$(SIGNATURES)
"""
function compute_density(df:: KNNDensity,  points)

    d, n  = size(points)
    kdtree = KDTree(points)
    k = df.k
    idxs, dists = knn(kdtree, points, k)

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
