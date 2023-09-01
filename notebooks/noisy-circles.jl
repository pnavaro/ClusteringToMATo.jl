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

# # Noisy circles

using ClusteringToMATo
using Distances
using NearestNeighbors
using Plots
using Random

# ## Create the data set

rng = MersenneTwister(1234)
points, labels = noisy_circles(rng, 1000)
scatter(points[1,:], points[2,:], c = labels,
aspect_ratio=1, ms = 3, palette = :rainbow)

# ## Run the C++ program written by original authors
#
# Save the data set to a txt file and run the program
# +
using DelimitedFiles
open("noisy_circles.txt", "w") do io
    writedlm(io, points')
end

run(`./ToMATo/main_w_density noisy_circles.txt 10 0.2 1e20`)
# -

# Read the output persistence diagram and plot it

pairs = readdlm("diagram.txt")
pairs[isinf.(pairs)] .*= -1
intervals = [PersistenceInterval(p...) for p in eachrow(pairs)]
pd = PersistenceDiagram(intervals)
plot(pd)

# We can compute our two clusters by setting the threshold to 1500

run(`./ToMATo/main_w_density noisy_circles.txt 10 0.2 1500`)
clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(points[1,:], points[2,:], color = Int.(clusters), aspect_ratio=1, ms=2, markerstrokewidth=0)
# ## Use the Julia implementation

# +
graph = compute_graph(KNNGraph(10), points);
f = compute_density(KNNDensity(50), points)
labels, diagram = compute_persistence( f, graph, Inf);

plot(diagram, infinity = 1)
# -

labels, diagram = compute_persistence( f, graph, 0.5);
scatter(points[1,:], points[2,:], c = labels, aspect_ratio=1 )

# ## Density function

x = LinRange(-2,2,100)
y = LinRange(-2,2,100)
dtm = zeros(100,100)
kdtree = KDTree(points)
k = 30
for i = 1:100, j = 1:100
    idxs, dists = knn(kdtree, [x[i], y[j]], k)
    dtm[i, j] = sqrt(sum(dists.^2) / k)
end
surface(x, y, -dtm)

scatter( points[1,:], points[2,:], -f, markerstrokewidth=0, ms = 2, markeralpha = 0.3)


