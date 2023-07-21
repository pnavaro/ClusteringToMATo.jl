using RecipesBase

@recipe function f(intervals::Dict{Int,Tuple{Float64,Float64}}; τ = 0.0)
        
    aspect_ratio := :equal

    birth = getindex.(values(intervals), 1)
    death = getindex.(values(intervals), 2)
    lim_min, lim_max = get(plotattributes, :xlims, extrema(filter(isfinite, death)))

    @series begin

        seriestype := :scatter
        birth, min.(death, lim_max)

    end
    
    @series begin
        seriescolor := :green
        [lim_min, lim_max-τ], [lim_min+τ, lim_max]
    end

    primary := false
    legend --> :none
    title := "persistence diagram"
    xlabel := "birth"
    ylabel := "death"

    (lim_min-1):(lim_max+1), (lim_min-1):(lim_max+1)

end

"""
$(SIGNATURES)
"""
function compute_persistence(points, f, graph, τ)
    
    d, n = size(points)

    intervals = Dict{Int,Tuple{Float64,Float64}}()
    v = sortperm(f, rev = true) # sort vertices using f
    f .= f[v] # sort f
    vertices_corr_inv = Dict(zip(v, 1:n)) #indexes of vertices in f
    G = [[vertices_corr_inv[i] for i in subset] for subset in graph[v]]
    𝒰 = IntDisjointSets(n)
    for i = eachindex(v)
        𝒩 = [j for j in G[i] if j < i]
        if length(𝒩) == 0
            intervals[i] = (f[i], Inf)
        else
            g = 𝒩[argmax(view(f, 𝒩))] # approximate gradient at vertex i
            eᵢ = find_root!(𝒰, g) # r(eᵢ)
            union!(𝒰, eᵢ, i) # Attach vertex i to the entry eᵢ
            for j in 𝒩
                e = find_root!(𝒰, j) # r(e)
                if e != eᵢ && min(f[e], f[eᵢ]) <= f[i] + τ # merge
                    if f[e] < f[eᵢ]
                        union!(𝒰, eᵢ, e)
                        intervals[j] = (f[e], f[eᵢ])
                    else
                        union!(𝒰, e, eᵢ)
                        intervals[i] = (f[eᵢ], f[e])
                    end 
                    eᵢ = find_root!(𝒰, e)   
                end
            end
        end
    end
    # the collection of entries e of 𝒰 such that f(r(e)) ≥ τ
    s = Set{Int}([])
    for i = 1:n
        g = find_root!(𝒰, i) #  r(e)
        if f[g] >= τ 
           push!(s, g)
        end
    end

    labels = zeros(Int, n)
    for (c,j) in enumerate(s), i in 1:n
        if in_same_set(𝒰, j, i)
            labels[v[i]] = c
        end
    end

    return labels, intervals

end

