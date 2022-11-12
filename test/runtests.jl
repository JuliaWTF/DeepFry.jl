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
                new_img = f(default_rng(), img)
                @test size(new_img) == size(img)
                @test eltype(new_img) == eltype(img)
                @test all(!isnan, new_img)
            end
        end
    end
    @testset "Test color frying" begin
        for (name, f) in DeepFry.COLOR_FRYING
            @testset "Effect $name" begin
                new_img = f(default_rng(), img)
                @test size(new_img) == size(img)
                @test eltype(new_img) == eltype(img)
                @test all(!isnan, new_img)
            end
        end
    end
end

using DeepFry: RGB
img = rand(RGB, 300, 500)
deepfry(img; madness=8, nostalgia=true)

img = TestImages.testimage("mountainstream")
deepfry(img)
img = TestImages.testimage("cameraman")
DeepFry.swirl(default_rng(), img, 0, 10, minimum(size(img)) ÷ 2)
new_img = DeepFry.checker_warp(img; crop=false, scaling=0.3)
DeepFry.ridged_warp(img; scaling=0.5)
using DeepFry: CoherentNoise

source = CoherentNoise.checkered_2d()

CoherentNoise.gen_image(CoherentNoise.scale(source, 0.1))

deepfry(img)

# mosaicview(pushfirst!([f(default_rng(), img) for (n, f) in pairs(DeepFry.STRUCTURE_FRYING)], img);nrow=2, fillvalue=colorant"white")
# mosaicview(pushfirst!([f(default_rng(), img) for (n, f) in pairs(DeepFry.COLOR_FRYING)], img);nrow=2, fillvalue=colorant"white")
