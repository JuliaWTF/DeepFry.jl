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
            new_img = f(default_rng(), img)
            if any(isnan, new_img)
                error(name)
            end
        end
    end
    @testset "Test color frying" begin
        for (name, f) in DeepFry.COLOR_FRYING
            new_img = f(default_rng(), img)
            if any(isnan, new_img)
                error(name)
            end
        end
    end
end

img = TestImages.testimage("mountainstream")
DeepFry.swirl(default_rng(), img)


deepfry(img)

# mosaicview(pushfirst!([f(default_rng(), img) for (n, f) in pairs(DeepFry.STRUCTURE_FRYING)], img);nrow=2, fillvalue=colorant"white")
# mosaicview(pushfirst!([f(default_rng(), img) for (n, f) in pairs(DeepFry.COLOR_FRYING)], img);nrow=2, fillvalue=colorant"white")
