using DeepFry
using Test
using TestImages
using ImageShow

@testset "DeepFry.jl" begin
    # Write your tests here.
end


img = TestImages.testimage("mountainstream")
deepfry(img)