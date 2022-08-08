using DeepFry
using Test
using TestImages
using ImageShow
using MosaicViews
using Random: default_rng

@testset "DeepFry.jl" begin
    img = TestImages.testimage("mountainstream")
    # Write your tests here.
end


img = TestImages.testimage("mountainstream")
deepfry(img)

# mosaicview(pushfirst!([f(default_rng(), img) for (n, f) in pairs(DeepFry.STRUCTURE_FRYING)], img);nrow=2, fillvalue=colorant"white")
# mosaicview(pushfirst!([f(default_rng(), img) for (n, f) in pairs(DeepFry.COLOR_FRYING)], img);nrow=2, fillvalue=colorant"white")
    
end