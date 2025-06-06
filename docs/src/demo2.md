# TDA examples

```@example demo2
using Plots
using DelimitedFiles
using ClusteringToMATo
gr(fmt = :png) # useful to plot a large size of scatter points
options = (ms=1, aspect_ratio=1, markerstrokewidth=0)
```

```@example demo2
download("https://raw.githubusercontent.com/MathieuCarriere/sklearn-tda/master/example/inputs/spiral_w_o_density.txt", 
"spiral_w_o_density.txt")

points = collect(transpose(readdlm(joinpath("spiral_w_o_density.txt"))))
```

```@example demo2
g = BallGraph(87)
f = KNNDensity(87)
tau = 7.5e-7

labels, intervals = tomato(points, g, f, tau)

scatter(points[1, :], points[2, :], c = labels; options...)
```

```@example demo2
download("https://raw.githubusercontent.com/MathieuCarriere/sklearn-tda/master/example/inputs/toy_example_w_o_density.txt",
"toy_example_w_o_density.txt") 
toy = collect(transpose(readdlm(joinpath("toy_example_w_o_density.txt"))))
```

```@example demo2
g = BallGraph(1.0)
f = KNNDensity(100)
tau = 0.01

labels, intervals = tomato(toy, g, f, tau)

scatter(view(toy,1, :), view(toy,2,:), c = labels; options... )
```
