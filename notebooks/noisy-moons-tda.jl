# ---
# jupyter:
#   jupytext:
#     formats: jl:light,ipynb
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

# # Noisy moons with Julia TDA

# ## Create the data set

using Random, Plots
import ClusteringToMATo
rng = MersenneTwister(1234)
points, labels = ClusteringToMATo.noisy_moons(rng, 500)
options = (ms = 2, markerstrokewidth=0, aspect_ratio = 1, xlims=(-2,2), ylims=(-2,2))
scatter(points[1,:], points[2,:], c = labels; options...)

# ## Run the C++ program written by original authors
#
# Save data set to file

using DelimitedFiles
open("noisy_moons.txt", "w") do io
    writedlm(io, points')
end

# run the program and read the output persistence diagram 

using PersistenceDiagrams
run(`./ToMATo/main_w_density noisy_moons.txt 30 0.2 1e20`)
pairs = readdlm("diagram.txt")
pairs[isinf.(pairs)] .*= -1
intervals = [PersistenceInterval(p...) for p in eachrow(pairs)]
pd = PersistenceDiagram(intervals)
plot(pd)

# We can see the two clusters with infinite life and set the threshold to 200

run(`./ToMATo/main_w_density noisy_moons.txt 30 0.2 90`)
clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(points[1,:], points[2,:], color = Int.(clusters); options...)

# ## Use the JuliaTDA implementation

# +
import Pkg
Pkg.add("Graphs")
Pkg.add(url="https://github.com/JuliaTDA/GeometricDatasets.jl")
Pkg.add(url="https://github.com/vituri/Quartomenter.jl")
Pkg.add(url="https://github.com/JuliaTDA/ToMATo.jl")

using ToMATo
import GeometricDatasets
# -

g = proximity_graph(points, 0.2)
k = x -> exp(-(x / 2)^2)
ds = GeometricDatasets.Filters.density(points, kernel_function = X -> X .|> k |> sum)

plot([0.0, 1.0], [1.0, 1.0])

# +
import Graphs

function graph_plot(points, graph)
    p = scatter(points[1,:], points[2,:],  markerstrokewidth=0)
    for e in Graphs.edges(graph)
        x1, y1 = points[:,e.src]
        x2, y2 = points[:,e.dst]
        plot!(p, [x1, x2], [y1, y2], color = :black, lw = 0.5, alpha = 0.5, legend = false)
    end
    p
end
# -

graph_plot(points, g)

clusters, births_and_deaths = tomato(points, g, ds, Inf)

# +
intervals = [PersistenceInterval(v...) for v in values(births_and_deaths)]
diagram = PersistenceDiagram(intervals)

plot(diagram)
# -

clusters, births_and_deaths = tomato(points, g, ds, 0.1)

scatter(points[1,:], points[2,:], color = clusters; options...)
