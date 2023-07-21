# ClusteringToMATo.jl

Documentation for ClusteringToMATo.jl

```@autodocs
Modules = [ClusteringToMATo]
Order   = [:type, :function]
```

## First example

## Parameter selection

ToMATo takes in three inputs: the neighborhood graph G, the density
estimator f, and the merging parameter τ. 

- Neighborhood graph G. ToMATo relies on the neighborhood
  information encoded in the input graph G. Two options are available:

  + connects two data points when they lie within distance δ of each other. 
    Different choices of ``\delta`` may reveal different structures. This
    is why we recommend running ToMATo at several scales. For too large values
    of δ there will be no real structure in the persistence diagram, while too small
    values will produce too many infinitely prominent peaks in the
    persistence diagram, corresponding to the connected components of the graph.

  + k-nearest neighbor graph. You get correct clusters under a suitable 
    choice of parameter k accomplished by trial-and-error.

- Density estimator f. Several are available: truncated Gaussian kernel 
  estimator, and the distance to a measure. Each of these estimators uses 
  one or two parameters.

- Merging parameter τ. It determines which peaks of f are considered significant. 
  To choose τ, call the function with τ set to `Inf`, and
  plot the persistence diagram. It reveals the topological structure of f, providing the height 
  and prominence of each peak of f. In cases where the persistence diagram of f shows a large gap 
  separating a small set of k highly prominent peaks from the rest of the 
  structure, we infer that the number of clusters is likely to be k, 
  and so you can set τ to be any value between the prominences of the k 
  distinguished peaks and the prominences of the rest of the persistence diagram. 
  By default, we try to detect the gap automatically. we sort the points 
  in the persistence diagram by decreasing prominence, and then we look for the largest drop 
  in the sequence of prominences.

