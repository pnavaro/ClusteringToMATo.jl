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

# # ToMATo: a Topological Mode Analysis Tool
#
# ## Toy data set
#

# +
using DelimitedFiles, Plots, PersistenceDiagrams

gr( fmt = :png)

toy = readdlm("ToMaTo/inputs/toy_example_w_density.txt")

scatter(toy[:,1], toy[:,2], marker_z = toy[:,3], aspect_ratio=1, ms=2, markerstrokewidth=0, size(500,500))
# -

# run the program with delta=0.25 and tau=1e20.

run(`./ToMATo/main ToMATo/inputs/toy_example_w_density.txt 0.25 1e20`)

# - `0.25` is the value of radius delta (a.k.a. Rips radius) to be used
#   in the construction of the neighborhood (Rips) graph.
#
# - `1e20` is the values of the threshold tau on the prominence of the
#   clusters to be used for merging clusters. It also serves as a
#   threshold on the heights of the peaks, so any cluster of height less
#   than tau is treated as background noise.
#
#

# You can then visualize the persistence diagram encoded in diagram.txt 

pairs = readdlm("diagram.txt")
pairs .*= -1
intervals = [PersistenceInterval(p...) for p in eachrow(pairs)]
pd = PersistenceDiagram(intervals)
plot(pd)

# It then shows the thresholding line superimposed to the persistence
# diagram. This may help users find relevant values for tau. Once
# this step is done, you can rerun the clustering program with the
# chosen value of tau :

run(`./ToMATo/main ToMATo/inputs/toy_example_w_density.txt 0.25 1e3`);

# and visualize the corresponding clustering in clusters.txt. In this
# example, the choice of tau reduces the number of clusters to 6.

clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(toy[:,1], toy[:,2], color = Int.(clusters), aspect_ratio=1, ms=2, markerstrokewidth=0)

# Finally, you can compare your result with the one obtained by the 1976
# paper by Koontz et al. by rerunning the program with tau=0:

run(`./ToMATo/main ./ToMATo/inputs/toy_example_w_density.txt 0.25 0`)

clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(toy[:,1], toy[:,2], color = Int.(clusters), aspect_ratio=1, ms=2, markerstrokewidth=0)

# ## Other examples:

run(`./ToMATo/main ./ToMATo/inputs/spiral_w_density.txt 10 1e-3`)

# -> gives 2 spiral-shaped clusters separated from the background noise 

spiral = readdlm("ToMaTo/inputs/spiral_w_density.txt")
clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(spiral[:,1], spiral[:,2], color = Int.(clusters), aspect_ratio=1, ms=2, markerstrokewidth=0)

run(`./ToMATo/main ./ToMATo/inputs/spiral_w_density.txt 25 1e-3`)

# gives 2 clusters spanning the entire data set (no background noise)

clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(spiral[:,1], spiral[:,2], color = Int.(clusters), aspect_ratio=1, ms=2, markerstrokewidth=0)

# ## Data sets without density information:
#
# If you have a point cloud without any density information attached
# to it, you can use ./main_w_density, which first estimates the density
# at each data point using the (inverse of the) distance to a measure,
# and then runs the same clustering code as ./main. There is one
# additional parameter to be tuned: the number k of neighbors to use when
# computing the distance to a measure. The rest of the arguments are the
# same as above.
#
# For instance, on the same example as above you may run the density
# estimator with k=200:

using ClusteringToMATo

df = compute_density(DTM(200), toy')
scatter(toy[:,1], toy[:,2], marker_z = df, aspect_ratio=1, ms=3, markerstrokewidth=0, size(500,500))

run(`./ToMATo//main_w_density ./ToMATo/inputs/toy_example_w_o_density.txt 200 0.25 1e20`) 

# You can then visualize the diagram and find that choosing
# tau=2 should give the correct number of clusters. 

pairs = readdlm("diagram.txt")
pairs .*= -1
intervals = [PersistenceInterval(p...) for p in eachrow(pairs)]
pd = PersistenceDiagram(intervals)
plot(pd)

# Afterwards, you can
# re-run the clustering with the new threshold:

run(`./ToMATo/main_w_density ./ToMATo/inputs/toy_example_w_o_density.txt 200 0.25 2`) 

clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(toy[:,1], toy[:,2], color = Int.(clusters), aspect_ratio=1, ms=2, markerstrokewidth=0)


