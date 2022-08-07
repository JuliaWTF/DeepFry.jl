using DeepFry
using Test
using TestImages
using ImageShow

@testset "DeepFry.jl" begin
    img = TestImages.testimage("mountainstream")
    # Write your tests here.
end


img = TestImages.testimage("mountainstream")
deepfry(img)