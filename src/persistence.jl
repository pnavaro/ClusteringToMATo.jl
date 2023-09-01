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
            e_i = find_root!(𝒰, g) # r(eᵢ) cluster's root
            e_i = union!(𝒰, e_i, i) # Attach vertex i to the entry eᵢ
            for j in 𝒩 # go through the neighbors to see if their clusters can be merges with eᵢ
                e_j = find_root!(𝒰, j) # r(e) # find root of the neighbor
                @assert f[e_j] >= f[i]
                if e_i != e_j
                    if min(f[e_i], f[e_j]) <= f[i] + τ # merge
                        if f[e_j] <= f[e_i]
                            intervals[e_j] = PersistenceInterval(f[e_j], f[i])
                            e_i = union!(𝒰, e_i, e_j)
                        else
                            intervals[e_i] = PersistenceInterval(f[e_i], f[i])
                            e_i = union!(𝒰, e_j, e_i)
                        end 
                    end
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

    labels = zeros(Int, n)
    for (c,j) in enumerate(s), i in 1:n
        if in_same_set(𝒰, j, i)
            labels[v[i]] = c
        end
    end

    return labels, PersistenceDiagram(collect(values(intervals)), threshold=τ)

end

