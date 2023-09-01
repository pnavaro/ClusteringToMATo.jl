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

using Plots
using DelimitedFiles
using ClusteringToMATo
gr(fmt = :png) # useful to plot a large size of scatter points
options = (ms=1, aspect_ratio=1, markerstrokewidth=0)

download("https://raw.githubusercontent.com/MathieuCarriere/sklearn-tda/master/example/inputs/spiral_w_o_density.txt", 
"spiral_w_o_density.txt")
spiral = collect(transpose(readdlm(joinpath("spiral_w_o_density.txt"))))

download("https://raw.githubusercontent.com/MathieuCarriere/sklearn-tda/master/example/inputs/toy_example_w_o_density.txt",
"toy_example_w_o_density.txt") 
toy = collect(transpose(readdlm(joinpath("toy_example_w_o_density.txt"))))

# +
@time labels, intervals = tomato(spiral, BallGraph(87), KNNDensity(87), 7.5e-7)

scatter(spiral[1, :], spiral[2, :], c = labels; options...)
# -

@time labels, intervals = tomato(toy, BallGraph(1.0), KNNDensity(100), 0.01)
scatter(view(toy,1, :), view(toy,2,:), c = labels; options... )


