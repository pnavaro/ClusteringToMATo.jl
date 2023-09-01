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
using ClusteringToMATo
using Plots
using DelimitedFiles
import Clustering

function read_csv(filepath)
    data, columns = readdlm(filepath, ',',  header=true)
    return collect(data[:,2:end]'), Int.(data[:,1])
end

# +
points, true_labels = read_csv(joinpath("data", "TwoDiamonds.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], c = true_labels, 
ms=3, aspect_ratio=:equal, markerstrokewidth=0,label="")

@time labels, intervals = tomato(points, 2, 0.2, 20, 0.25)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], c = labels, 
      label="", ms=3, markerstrokewidth=0, aspect_ratio=1)

# +
points, true_labels = read_csv(joinpath("data", "Lsun.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], c = true_labels, 
ms=3, aspect_ratio=:equal, markerstrokewidth=0,label="")

@time labels, intervals = tomato(points, 1, 5, 5, 0.6)

println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], c = labels, 
      label="", ms=3, markerstrokewidth=0, aspect_ratio=1)

# +
points, true_labels = read_csv(joinpath("data", "Atom.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], points[3, :], c = true_labels, 
ms=3, aspect_ratio=:equal, markerstrokewidth=0,label="")

@time labels, intervals = tomato(points, 2, 15, 10, 0.001)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], points[3, :], c = labels, 
      label="", ms=3, markerstrokewidth=0, aspect_ratio=1)

# +
points, true_labels = read_csv(joinpath("data", "Chainlink.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], points[3, :], c = true_labels, 
ms=3, aspect_ratio=:equal, markerstrokewidth=0,label="")

@time labels, intervals = tomato(points, 1, 10, 100, 0.15)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], points[3, :], c = labels, 
      label="", ms=3, markerstrokewidth=0, aspect_ratio=1)

# +
points, true_labels = read_csv(joinpath("data", "Engytime.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], c = true_labels, 
ms=1, aspect_ratio=:equal, markerstrokewidth=0,label="")
@time labels, intervals = tomato(points, 2, 1, 10, 0.1)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], c = labels, 
      label="", ms=1, markerstrokewidth=0, aspect_ratio=1)

# +
points, true_labels = read_csv(joinpath("data", "Hepta.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], points[3,:], c = true_labels, 
ms=2, aspect_ratio=:equal, markerstrokewidth=0,label="")
@time labels, intervals = tomato(points, 1, 20, 20, 0.005)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], points[3, :], c = labels, 
      label="", ms=2, markerstrokewidth=0, aspect_ratio=1)

# +
points, true_labels = read_csv(joinpath("data", "Tetra.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], points[3,:], c = true_labels, 
ms=2, aspect_ratio=:equal, markerstrokewidth=0,label="")
@time labels, intervals = tomato(points, 1, 100, 100, 0.01)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], points[3, :], c = labels, 
      label="", ms=2, markerstrokewidth=0, aspect_ratio=1)

# +
points, true_labels = read_csv(joinpath("data", "WingNut.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], c = true_labels, 
ms=2, aspect_ratio=:equal, markerstrokewidth=0,label="")
@time labels, intervals = tomato(points, 2, 0.2, 20, 0.25)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], c = labels, 
      label="", ms=2, markerstrokewidth=0, aspect_ratio=1)
# -




