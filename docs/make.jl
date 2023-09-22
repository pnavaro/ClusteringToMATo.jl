push!(LOAD_PATH,"../src/")

using Documenter
using ClusteringToMATo
using Plots 

ENV["GKSwstype"] = "100"

makedocs(
         sitename = "ClusteringToMATo.jl",
         modules = [ClusteringToMATo],
         format=Documenter.HTML(;
         prettyurls=get(ENV, "CI", "false") == "true",
         mathengine = MathJax(Dict(
            :TeX => Dict(
                :equationNumbers => Dict(:autoNumber => "AMS"),
                :Macros => Dict()
            )
         )),
         canonical="https://pnavaro.github.io/ClusteringToMATo.jl",
         assets=String[],
         ),
         doctest = false,
         pages = [
                  "Home" => "index.md",
                  "FCPS data" => "demo1.md",
                  "TDA datasets" => "demo2.md" ,
                  "ToMATo C++" => "tomato_cpp.md" 
                 ])

deploydocs(;
    branch = "gh-pages",
    devbranch = "main",
    repo   = "github.com/pnavaro/ClusteringToMATo.jl"
)
