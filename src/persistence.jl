using PersistenceDiagrams

export compute_persistence

"""
$(SIGNATURES)
"""
function compute_persistence(f, graph, τ)
    
    n = length(f)

    v = sortperm(f, rev = true) # sort vertices using f
    sort!(f, rev = true) # sort f
    # get neighbors
    vertices_corr_inv = Dict(zip(v, 1:n)) #indexes of vertices in sorted f
    G = [[vertices_corr_inv[i] for i in subset] for subset in graph[v]]
    𝒰 = IntDisjointSets(n)
    intervals = Dict{Int,PersistenceInterval}()
    for i = eachindex(v)
        𝒩 = [j for j in G[i] if j < i]
        if length(𝒩) == 0
            intervals[i] = PersistenceInterval(f[i], Inf)
        else
            g = 𝒩[argmax(view(f, 𝒩))] # approximate gradient at vertex i
            eᵢ = find_root!(𝒰, g) # r(eᵢ) cluster's root
            union!(𝒰, eᵢ, i) # Attach vertex i to the entry eᵢ
            for j in 𝒩
                e = find_root!(𝒰, j) # r(e)
                if e != eᵢ && min(f[e], f[eᵢ]) <= f[i] + τ # merge
                    if f[e] < f[eᵢ]
                        intervals[e] = PersistenceInterval(f[e], f[eᵢ])
                        union!(𝒰, eᵢ, e)
                    else
                        intervals[eᵢ] = PersistenceInterval(f[eᵢ], f[eᵢ])
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

    return labels, PersistenceDiagram(collect(values(intervals)), threshold=τ)

end

