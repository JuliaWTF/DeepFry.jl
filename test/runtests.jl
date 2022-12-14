using DeepFry
using Test
using TestImages
using ImageShow
using MosaicViews
using Random: MersenneTwister, default_rng

@testset "DeepFry.jl" begin
    img = TestImages.testimage("mountainstream")
    @testset "Test structure frying" begin
        for (name, f) in DeepFry.STRUCTURE_FRYING
            @testset "Effect $name" begin
                new_img = f(img; rng=default_rng())
                @test size(new_img) == size(img)
                @test eltype(new_img) == eltype(img)
                @test all(!isnan, new_img)
            end
        end
    end
    @testset "Test color frying" begin
        for (name, f) in DeepFry.COLOR_FRYING
            @testset "Effect $name" begin
                new_img = f(img; rng=default_rng())
                @test size(new_img) == size(img)
                @test eltype(new_img) == eltype(img)
                @test all(!isnan, new_img)
            end
        end
    end
    @testset "Test standard frying" begin
        for f in DeepFry.STD_FRYING
            @testset "Effect $f" begin
                new_img = f(img; rng=default_rng())
                @test size(new_img) == size(img)
                @test eltype(new_img) == eltype(img)
                @test all(!isnan, new_img)
            end
        end
    end
end
