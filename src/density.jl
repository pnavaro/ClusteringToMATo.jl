abstract type AbstractDensityComputation end

struct BallDensity <: AbstractDensityComputation
    δ :: Float64
    BallDensity(δ) = new(δ)
end

"""
$(SIGNATURES)
"""
function (df::BallDensity)(points)

    n = size(points, 2)
    btree = BallTree(points)
    n_neighbors = inrangecount(btree, points, df.δ)

    return - (n_neighbors .+ 1) ./ n

end

struct DTM <: AbstractDensityComputation
    k :: Int
end

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
        f[i] = - sum(exp.(dists[i]*(-0.5)/df.h))
    end
    return f

end

struct GaussianCutoff <: AbstractDensityComputation
    δ :: Int
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
        f[i] = - sum(exp(dists[i,j]*(-0.5)/df.h) for j in idxs[i])
    end
    return f

end

struct DensityKNN  <: AbstractDensityComputation
    k :: Int
end

"""
$(SIGNATURES)
"""
function compute_density(df:: DensityKNN,  points)

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
