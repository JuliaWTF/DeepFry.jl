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
                new_img = f(img; rng = default_rng())
                @test size(new_img) == size(img)
                @test eltype(new_img) == eltype(img)
                @test all(!isnan, new_img)
            end
        end
    end
    @testset "Test color frying" begin
        for (name, f) in DeepFry.COLOR_FRYING
            @testset "Effect $name" begin
                new_img = f(img; rng = default_rng())
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

using DeepFry: RGB
img = rand(RGB, 2480, 3508)

img = TestImages.testimage("mountainstream")
img = load("/home/theo/Pictures/berlin_maker_faire.jpg")
img = DeepFry.imresize(img,floor.(Int, 3 .* size(img))...)
for i in 1:100
    new_img = deepfry(img; temperature=9)
    save("/home/theo/Pictures/deepfry_$(i).png", new_img)
end

deepfry(img)
fastfood("mountain.gif", img, 30)
img = TestImages.testimage("cameraman")
DeepFry.swirl(img, 0, 10, minimum(size(img)) ÷ 2)
new_img = DeepFry.checker_warp(img; crop=false, scaling=0.3)
DeepFry.ridged_warp(img; scaling=0.5)

deepfry(img)


