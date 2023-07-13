# ClusteringToMaTo.jl

Documentation for ClusteringToMaTo.jl

```@autodocs
Modules = [ClusteringToMaTo]
Order   = [:type, :function]
```

## First example

```@example circles
using Plots
using ClusteringToMaTo
using Ripserer

θ = LinRange(0, 2π, 61)[1:end-1]
unit_circle = vcat(cos.(θ)', sin.(θ)')
points = hcat(unit_circle, 0.3 .* unit_circle, 0.6 .* unit_circle)

scatter( points[1,:], points[2,:], aspect_ratio = 1)
```

```@example circles
results = ripserer(eachcol(points))
plot(results[2])
```

The three dots are the circles so you can fix the value of ``\tau = 0.15`` which is the minimal distance to the diagonal to keep these three clusters.

```@example circles
labels = data2clust(points; τ = 0.15)
scatter( points[1,:], points[2,:], c = labels,  aspect_ratio = 1)
```
