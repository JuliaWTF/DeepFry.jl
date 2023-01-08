using DeepFry
using DeepFry: RGB
using Test
using TestImages
using ImageShow
using MosaicViews
using Random: MersenneTwister, default_rng
img = rand(RGB, 2480, 3508)

img = TestImages.testimage("mountainstream")
img = load("/home/theo/Pictures/berlin_maker_faire.jpg")
img = DeepFry.imresize(img, floor.(Int, 3 .* size(img))...)
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
