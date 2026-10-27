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
    vertices_corr_inv = Dict(zip(v, 1:n)) # indexes of vertices in sorted f
    G = [[vertices_corr_inv[i] for i in subset] for subset in graph[v]]
    𝒰 = IntDisjointSets(n)
    root_of = collect(1:n)
    intervals = Dict{Int,PersistenceInterval}()

    for i = eachindex(v)
        𝒩 = [j for j in G[i] if j < i]
        if length(𝒩) == 0
            intervals[i] = PersistenceInterval(f[i], Inf)
        else
            g = 𝒩[argmax(view(f, 𝒩))] # approximate gradient at vertex i
            e_g = root_of[find_root!(𝒰, g)] # r(e_g) cluster root of steepest neighbor
            rep = union!(𝒰, e_g, i) # Attach vertex i to cluster of g
            root_of[rep] = e_g

            for j in 𝒩 # go through neighbors to merge clusters if less than τ-prominent
                e_i = root_of[find_root!(𝒰, i)]
                e_j = root_of[find_root!(𝒰, j)]
                if e_i != e_j
                    if min(f[e_i], f[e_j]) - f[i] < τ # prominence merge condition
                        if f[e_j] <= f[e_i]
                            intervals[e_j] = PersistenceInterval(f[e_j], f[i])
                            rep = union!(𝒰, e_i, e_j)
                            root_of[rep] = e_i
                        else
                            intervals[e_i] = PersistenceInterval(f[e_i], f[i])
                            rep = union!(𝒰, e_j, e_i)
                            root_of[rep] = e_j
                        end 
                    end
                end
            end
        end
    end

    # Assign cluster labels based on the connected components in 𝒰
    roots = unique([root_of[find_root!(𝒰, i)] for i in 1:n])
    root_to_label = Dict(r => idx for (idx, r) in enumerate(roots))

    labels = zeros(Int, n)
    for i in 1:n
        labels[v[i]] = root_to_label[root_of[find_root!(𝒰, i)]]
    end

    return labels, PersistenceDiagram(collect(values(intervals)), threshold=τ)

end

