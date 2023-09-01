# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     formats: ipynb,md,jl:light
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
using PersistenceDiagrams
gr(fmt = :png)

# ## Read data

toy = readdlm(joinpath( "ToMATo", "inputs", "toy_example_w_density.txt"))
points = collect(toy[:,1:2]')

scatter( points[1,:], points[2,:], aspect_ratio = 1, 
         ms = 3, marker_z = toy[:,3], palette = :jet, markerstrokewidth=0)

# +
τ = Inf
δ = 0.25
clusters = compute_graph(BallGraph(δ), points)
f = toy[:,3]
labels, intervals = tomato(points, clusters, f, τ)

plot(intervals)
# -

τ = 1000
labels, intervals = tomato(points, clusters, f, τ)
scatter( points[1,:], points[2,:], c = labels, ms=2, aspect_ratio = 1, markerstrokewidth=0)

τ = 0
labels, intervals = tomato(points, clusters, f, τ)
scatter( points[1,:], points[2,:], c = labels, ms=2, aspect_ratio = 1, markerstrokewidth=0)


