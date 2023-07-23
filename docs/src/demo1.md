# FCPS datasets examples

We use data from 

Ultsch, A.; Lötsch, J. The Fundamental Clustering and Projection Suite (FCPS): A Dataset Collection to Test the Performance of Clustering and Data Projection Algorithms. Data 2020, 5, 13. https://doi.org/10.3390/data5010013

```@example demo1
using ClusteringToMATo
using Plots
using DelimitedFiles
import Clustering

function read_csv(filepath)
    data, columns = readdlm(filepath, ',',  header=true)
    return collect(data[:,2:end]'), Int.(data[:,1])
end
```

```@example demo1
points, true_labels = read_csv(joinpath("data", "TwoDiamonds.csv"))
p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], c = true_labels, 
ms=3, aspect_ratio=:equal, markerstrokewidth=0,label="")

g = BallGraph(0.25)
f = KNNDensity(20)
tau = 0.25

@time labels, intervals = tomato(points, g, f, tau)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], c = labels, 
      label="", ms=3, markerstrokewidth=0, aspect_ratio=1)
```

```@example demo1
points, true_labels = read_csv(joinpath("data", "Lsun.csv"))
p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], c = true_labels, 
ms=3, aspect_ratio=:equal, markerstrokewidth=0,label="")
1
g = KNNGraph(10)
f = KNNDensity(5)
tau = 0.6
@time labels, intervals = tomato(points, g, f, tau)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], c = labels, 
      label="", ms=3, markerstrokewidth=0, aspect_ratio=1)
```

```@example demo1
points, true_labels = read_csv(joinpath("data", "Atom.csv"))
p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], points[3, :], c = true_labels, 
ms=3, aspect_ratio=:equal, markerstrokewidth=0,label="")

g = BallGraph(15)
f = KNNDensity(10)
tau = 0.0000515
@time labels, intervals = tomato(points, g, f, tau)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], points[3, :], c = labels, 
      label="", ms=3, markerstrokewidth=0, aspect_ratio=1)
```

```@example demo1
points, true_labels = read_csv(joinpath("data", "Chainlink.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], points[3, :], c = true_labels, 
ms=3, aspect_ratio=:equal, markerstrokewidth=0,label="")

g = KNNGraph(10)
f = KNNDensity(100)
tau = 0.2
@time labels, intervals = tomato(points, g, f, tau)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], points[3, :], c = labels, 
      label="", ms=3, markerstrokewidth=0, aspect_ratio=1)
```

```@example demo1
points, true_labels = read_csv(joinpath("data", "EngyTime.csv"))

p = plot(layout=(1,2))
scatter!(p[1,1], points[1,:], points[2,:], c = true_labels, 
ms=3, aspect_ratio=:equal, markerstrokewidth=0,label="")

g = BallGraph(1.0)
f = KNNDensity(10)
tau = 0.00000001
@time labels, intervals = tomato(points, g, f, tau)
println(" NMI = $(Clustering.mutualinfo(true_labels, labels))")
scatter!(p[1,2], points[1,:], points[2, :], c = labels, 
      label="", ms=3, markerstrokewidth=0, aspect_ratio=1)
```
