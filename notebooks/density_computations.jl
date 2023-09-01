# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.15.1
#   kernelspec:
#     display_name: Julia 1.9
#     language: julia
#     name: julia-1.9
# ---

# +
using DelimitedFiles
using Distances
using NearestNeighbors
using Plots
using ClusteringToMATo
gr(fmt = :png)

toy = readdlm(joinpath("ToMATo","inputs","toy_example_w_density.txt"))
scatter(toy[:,1], toy[:,2], marker_z = toy[:,3], markerstrokewidth=0, aspect_ratio=1)
# -

points = collect(transpose(toy[:,1:2]))
f = compute_density(KNNDensity(200), points)
scatter(points[1,:], points[2,:], marker_z = f, markerstrokewidth=0, aspect_ratio=1)

f = compute_density(DTM(200), points) 
scatter(points[1,:], points[2,:], marker_z = f, markerstrokewidth=0, aspect_ratio=1)

f = compute_density(BallDensity(0.25), points)
scatter(points[1,:], points[2,:], marker_z = f, markerstrokewidth=0, aspect_ratio=1)

f = compute_density(GaussianNN(200, 0.1), points)
scatter(points[1,:], points[2,:], marker_z = f, markerstrokewidth=0, aspect_ratio=1)

f = compute_density(GaussianCutoff(0.25, 0.1), points)
scatter(points[1,:], points[2,:], marker_z = f, markerstrokewidth=0, aspect_ratio=1)

# +
using KernelDensity

u = kde(points')

contour(u.x, u.y, u.density, aspect_ratio=1)
# -

surface(u.x, u.y, u.density)


