using RecipesBase

@recipe function f(intervals::Dict{Int,Tuple{Float64,Float64}}; τ = 0.0)
        
    aspect_ratio := :equal

    birth = getindex.(values(intervals), 1)
    death = getindex.(values(intervals), 2)
    lim_min, lim_max = get(plotattributes, :xlims, (0., maximum(birth)))

    @series begin

        seriestype := :scatter
        birth, min.(death, lim_max)

    end
    
    @series begin
        seriescolor := :green
        [lim_min+τ, lim_max], [0, lim_max-τ]
    end

    primary := false
    legend --> :none
    title := "persistence diagram"
    xlabel := "birth"
    ylabel := "death"
    xlims --> (0., maximum(birth))

    lim_min:lim_max, lim_min:lim_max

end

export compute_persistence

"""
$(SIGNATURES)
"""
function compute_persistence(f, graph, τ)
    
    n = length(f)

    intervals = Dict{Int,Tuple{Float64,Float64}}()
    v = sortperm(f, rev = true) # sort vertices using f
    sort!(f, rev = true) # sort f
    # get neighbors
    vertices_corr_inv = Dict(zip(v, 1:n)) #indexes of vertices in sorted f
    G = [[vertices_corr_inv[i] for i in subset] for subset in graph[v]]
    𝒰 = IntDisjointSets(n)
    for i = eachindex(v)
        𝒩 = [j for j in G[i] if j < i]
        if length(𝒩) == 0
            intervals[i] = (f[i], f[i])
        else
            g = 𝒩[argmax(view(f, 𝒩))] # approximate gradient at vertex i
            eᵢ = find_root!(𝒰, g) # r(eᵢ) cluster's root
            union!(𝒰, eᵢ, i) # Attach vertex i to the entry eᵢ
            for j in 𝒩
                e = find_root!(𝒰, j) # r(e)
                if e != eᵢ && min(f[e], f[eᵢ]) <= f[i] + τ # merge
                    if f[e] < f[eᵢ]
                        intervals[eᵢ] = (f[eᵢ], f[i])
                        union!(𝒰, eᵢ, e)
                    else
                        intervals[e] = (f[e], f[i])
                        union!(𝒰, e, eᵢ)
                    end 
                    eᵢ = find_root!(𝒰, e)   
                end
            end
        end
    end

    # the collection of entries e of 𝒰 such that f(r(e)) ≥ τ
    s = Set{Int}([])
    if isfinite(τ)
        for e = 1:n
            r = find_root!(𝒰, e) #  r(e)
            if f[r] >= τ 
                push!(s, r)
            else
                delete!(intervals, r)
            end
        end
    end
    println("clusters : $(length(s))")

    labels = zeros(Int, n)
    for (c,j) in enumerate(s), i in 1:n
        if in_same_set(𝒰, j, i)
            labels[v[i]] = c
        end
    end

    return labels, intervals

end

