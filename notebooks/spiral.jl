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
using DelimitedFiles, Plots
gr(fmt=:png)

spiral =readdlm(joinpath("ToMATo","inputs","spiral_w_density.txt"))
scatter(spiral[:,1], spiral[:,2], marker_z=spiral[:,3], ms=0.2, aspect_ratio = 1)
# -

# ## Install ToMATo
#
# https://geometrica.saclay.inria.fr/data/Steve.Oudot/clustering/
#
# ~~~
# wget http://geometrica.saclay.inria.fr/data/Steve.Oudot/clustering/ToMATo_code.tgz
# tar zxf ToMATo_code.tgz
# cd ToMATo
# wget http://www.cs.umd.edu/~mount/ANN/Files/1.1.2/ann_1.1.2.tar.gz
# tar zxvf ann_1.1.2.tar.gz
# cd ann_1.1.2
# make
# cd -
# make ANNLIB=./ann_1.1.~
# ~~~

# ## 2 spiral-shaped clusters separated from the background noise 

run(`./ToMATo/main ToMATo/inputs/spiral_w_density.txt 10 1e-3`)

pairs = readdlm("diagram.txt")
scatter(pairs[:,1], pairs[:,2])

# +
clusters = vec(readdlm("clusters.txt"))
v = .!isnan.(clusters)

scatter(spiral[v,1], spiral[v,2], c = Int.(clusters[v]), ms=1, markerstrokewidth=0, aspect_ratio=1)
# -

run(`./ToMATo/main ToMATo/inputs/spiral_w_density.txt 25 1e-3`)

pairs = readdlm("diagram.txt")
scatter(pairs[:,1], pairs[:,2])

# +
clusters = Int.(vec(readdlm("clusters.txt")))

scatter(spiral[:,1], spiral[:,2], c = clusters, ms=1, markerstrokewidth=0, aspect_ratio=1)
# -


