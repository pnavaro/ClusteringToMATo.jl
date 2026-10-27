using ClusteringToMATo
using Test
using Random
using PersistenceDiagrams

@testset "ClusteringToMATo tests" begin
    @testset "Noisy circles" begin
        rng = MersenneTwister(1234)
        points, true_labels = noisy_circles(rng, 1000)
        graph = compute_graph(KNNGraph(10), points)
        f = compute_density(KNNDensity(50), points)

        # τ = Inf should produce the persistence diagram with 2 prominent clusters
        labels_inf, diagram = compute_persistence(copy(f), graph, Inf)
        @test diagram isa PersistenceDiagram
        @test length(diagram) > 0

        # With τ = 0.5, the 2 circles should be separated
        labels, _ = compute_persistence(copy(f), graph, 0.5)
        @test length(unique(labels)) == 2
        @test count(labels .== 1) + count(labels .== 2) == 1000
    end

    @testset "Noisy moons" begin
        rng = MersenneTwister(1234)
        points, true_labels = noisy_moons(rng, 1000)
        labels, diagram = tomato(points; graph = 1, k = 30, q = 30, τ = 1.0)
        @test length(unique(labels)) == 2
        @test count(labels .== 1) == 500
        @test count(labels .== 2) == 500
    end
end

