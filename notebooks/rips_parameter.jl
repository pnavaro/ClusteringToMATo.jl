# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.15.2
#   kernelspec:
#     display_name: Julia 1.9.3
#     language: julia
#     name: julia-1.9
# ---

# Generate some data points to test how works the graph building in ToMATo

using ClusteringToMATo
using DelimitedFiles
using PersistenceDiagrams
using Plots
using Sobol

s = SobolSeq(2)
n = 16
p = reduce(hcat, next!(s) for i = 1:n÷2)'
data = vcat(p, p .+ [1, 1]')
scatter(data[:,1], data[:,2], aspect_ratio=1)

open("sobol.txt", "w") do io
    writedlm(io, [data ones(n)])
end

run(`./ToMATo/main_w_density sobol.txt 10 0.5 1e20`)

points = collect(transpose(data))
f = compute_density(DTM(10), points)

sortperm(f, rev=true)

# +

graph = compute_graph(BallGraph(0.2), points);
graph
# -

# sort point cloud and retrieve permutation (for pretty output)

np_points = size(points, 2)
perm = collect(1:nb_points)

  std::sort(perm.begin(), perm.end(), Less_Than<vector<Point> >(point_cloud));
  // store inverse permutation as array of iterators on initial point cloud
  vector< vector<Point>::iterator> pperm;
  pperm.reserve(nb_points);
  for (int i=0; i<nb_points; i++)
    pperm.push_back(point_cloud.begin());
  for (int i=0; i<nb_points; i++)
    pperm[perm[i]] = (point_cloud.begin() + i);
  // operate permutation on initial point cloud 
  vector<Point> pc;
  pc.reserve(nb_points);
  for (int i=0; i<nb_points; i++)
    pc.push_back(point_cloud[i]);
  for (int i=0; i<nb_points; i++)
    point_cloud[i] = pc[perm[i]];

pairs = readdlm("diagram.txt")
pairs .*= -1
intervals = [PersistenceInterval(p...) for p in eachrow(pairs)]
pd = PersistenceDiagram(intervals)
plot(pd)

run(`./ToMATo/main sobol.txt 2 0.2`)

clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(data[:,1], data[:,2], color = Int.(clusters), aspect_ratio=1, ms=2, markerstrokewidth=0)

# +
f = compute_density(KNNDensity(10), points)
labels, diagram = compute_persistence( f, graph, Inf);

plot(diagram)
# -

labels, diagram = compute_persistence( f, graph, 0.1);
scatter(points[1,:], points[2,:], c = labels, aspect_ratio=1 )


