module DeepFry

using Colors: HSV, RGB
using ColorSchemes: prism
using DitherPunk: Bayer, FloydSteinberg, ClusteredDots, dither
using ImageFiltering: Kernel, imfilter
using ImageTransformations: imresize
using Random: default_rng, AbstractRNG
export deepfry


const prism = ColorSchemes.prism[1:10]
const COLOR_FRYING = Dict(
    "max saturation" => img -> begin
        img = HSV.(img)
        img = HSV.(getfield.(img, :h), 1.0, getfield.(img, :v))
        RGB.(img)
    end,
)
const STRUCTURE_FRYING = Dict(
    "dithering" => img -> dither(img, Bayer(3)),
    "color dithering" => img -> dither(img, FloydSteinberg(), prism[1:10]),
    "dot clustering" => img -> dither(img, ClusteredDots()),
    "pixelize" => img -> imresize(imresize(img, ratio = 1/10), ratio=10),
    "Laplacian filter" => img -> imfilter(img, Kernel.Laplacian()),
    "Gaussian filtering" => img -> imfilter(img, Kernel.gaussian(3)),
)

deepfry(img; maxdepth=5) = deepfry(default_rng(), img; maxdepth)

function deepfry(rng::AbstractRNG, img; maxdepth=5)
    for _ in 1:maxdepth
        name, f = rand(rng, STRUCTURE_FRYING)
        @info "running $name"
        img = f(img)
    end
    img
end


end
