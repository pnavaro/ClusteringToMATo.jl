# [Topological Mode Analysis C++ Tool](@id original_cpp)

- The conference version of the paper (high-level presentation, easy to read): [link](http://geometrica.saclay.inria.fr/team/Steve.Oudot/papers/cgos-pbc-09/cgos-pbcrm-11.pdf)
- The journal version of the paper (with the full technical details): [link](https://geometrica.saclay.inria.fr/data/Steve.Oudot/clustering/jacm_oudot.pdf)
- The paper presenting the soft clustering variant of the algorithm: [link](http://arxiv.org/abs/1406.7130)
- The C++ code + sample data sets:  [link](http://geometrica.saclay.inria.fr/data/Steve.Oudot/clustering/ToMATo_code.tgz)

The original author and main contact to get more details about this method is [Steve Oudot](http://geometrica.saclay.inria.fr/team/Steve.Oudot)

## Install C++ program

```bash
wget https://www.cs.umd.edu/~mount/ANN/Files/1.1.2/ann_1.1.2.tar.gz
tar zxvf ann_1.1.2.tar.gz
cd ann_1.1.2 && make linux-g++ && cd -
wget http://geometrica.saclay.inria.fr/data/Steve.Oudot/clustering/ToMATo_code.tgz
tar zxvf ToMATo_code.tgz
cd ToMATo/ && make ANNLIB=../ann_1.1.2 && cd -
```

```@example cpp
using DelimitedFiles, Plots, PersistenceDiagrams

toy = readdlm("./ToMATo/inputs/toy_example_w_density.txt")

scatter(toy[:,1], toy[:,2], marker_z = toy[:,3], aspect_ratio=1, ms=2, markerstrokewidth=0, size(500,500))
savefig("assets/toy_cpp1.png") # hide
nothing # hide
```
![](assets/toy_cpp1.png)

run the program with delta=0.25 and tau=1e20.

```@example cpp
run(`./ToMATo/main ./ToMATo/inputs/toy_example_w_density.txt 0.25 1e20`)
```
- `0.25` is the value of radius delta (a.k.a. Rips radius) to be used
  in the construction of the neighborhood (Rips) graph.

- `1e20` is the values of the threshold tau on the prominence of the
  clusters to be used for merging clusters. It also serves as a
  threshold on the heights of the peaks, so any cluster of height less
  than tau is treated as background noise.

You can then visualize the persistence diagram encoded in diagram.txt 

```@example cpp
pairs = readdlm("diagram.txt")
pairs .*= -1
intervals = [PersistenceInterval(p...) for p in eachrow(pairs)]
pd = PersistenceDiagram(intervals)
plot(pd)
savefig("assets/toy_cpp2.png") # hide
nothing # hide
```
![](assets/toy_cpp2.png)

It then shows the thresholding line superimposed to the persistence
diagram. This may help users find relevant values for tau. Once
this step is done, you can rerun the clustering program with the
chosen value of tau :

```@example cpp
run(`./ToMATo/main ./ToMATo/inputs/toy_example_w_density.txt 0.25 1e3`);
```

and visualize the corresponding clustering in clusters.txt. In this
example, the choice of tau reduces the number of clusters to 6.

```@example cpp
clusters = vec(readdlm("clusters.txt"))
clusters[isnan.(clusters)] .= 0
scatter(toy[:,1], toy[:,2], color = Int.(clusters), aspect_ratio=1, ms=2, markerstrokewidth=0)
savefig("assets/toy_cpp3.png") # hide
nothing # hide
```
![](assets/toy_cpp3.png)
