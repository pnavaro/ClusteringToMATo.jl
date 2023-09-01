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

# # Noisy moons

using ClusteringToMATo
using Distances
using NearestNeighbors
using PersistenceDiagrams
using Plots
using Random

# ## Create the data set

rng = MersenneTwister(1234)
points, labels = noisy_moons(rng, 1000)
scatter(points[1,:], points[2,:], c = labels,
aspect_ratio=1, ms = 3, palette = :rainbow)

# ## Run the C++ program written by original authors
#
# Save data set to file

using DelimitedFiles
open("noisy_moons.txt", "w") do io
    writedlm(io, points')
end

# run the program and read the output persistence diagram 

run(`./ToMATo/main_w_density noisy_moons.txt 30 0.2 1e20`)
pairs = readdlm("diagram.txt")
pairs[isinf.(pairs)] .*= -1
intervals = [PersistenceInterval(p...) for p in eachrow(pairs)]
pd = PersistenceDiagram(intervals)
plot(pd)

# We can see the two clusters with infinite life and set the threshold to 200

run(`./ToMATo/main_w_density noisy_moons.txt 30 0.2 200`)
clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(points[1,:], points[2,:], color = Int.(clusters), aspect_ratio=1, ms=2, markerstrokewidth=0)

# ## Use the Julia implementation

# +
graph = compute_graph(KNNGraph(30), points);
f = compute_density(KNNDensity(30), points)
labels, diagram = compute_persistence( f, graph, Inf);

plot(diagram)
# -

labels, diagram = compute_persistence( f, graph, 1.0);
scatter(points[1,:], points[2,:], c = labels, aspect_ratio=1 )
