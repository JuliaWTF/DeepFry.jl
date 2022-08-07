module DeepFry

using Colors: HSV, RGB
using ColorSchemes: ColorSchemes
using DitherPunk: Bayer, FloydSteinberg, ClusteredDots, dither
using Distributions
using LinearAlgebra
using ImageContrastAdjustment
using ImageFiltering: Kernel, imfilter
using ImageTransformations: imresize, warp
using OffsetArrays
using OrderedCollections: OrderedDict
using Random: default_rng, AbstractRNG
using StaticArrays
export deepfry, nuke

include("warping.jl")

const prism = ColorSchemes.prism[1:10]
COLOR_FRYING = OrderedDict(
    "max saturation" => (rng, img) -> begin
        img = HSV.(img)
        img = HSV.(getfield.(img, :h), rand(rng) * 0.2 + 0.8, getfield.(img, :v))
        RGB.(img)
    end,
    "equalizing contrast" => (rng, img) -> adjust_histogram(img, Equalization(nbins=rand(rng, 2:10))),
    "stretching constract" => (rng, img) -> adjust_histogram(img, ContrastStretching(t=3 * rand(rng), slope=rand(rng))),
    "color dithering" => (rng, img) -> dither(img, FloydSteinberg(), prism),
)
STRUCTURE_FRYING = OrderedDict(
    "dithering" => (rng, img) -> dither(img, Bayer(rand(1:3))),
    "dot clustering" => (rng, img) -> dither(img, ClusteredDots()),
    "pixelize" => (rng, img) -> begin
        r = rand(rng, 4:20)
        imresize(imresize(img, ratio = 1/r), ratio=r)
    end,
    "Laplacian filtering" => (rng, img) -> imfilter(img, Kernel.laplacian2d(rand(rng, 0:3))),
    "Gaussian filtering" => (rng, img) -> imfilter(img, Kernel.gaussian(rand(rng, 1:5))),
    "Gabor filtering" => (rng, img) -> imfilter(img, Kernel.gabor(rand(rng, truncated(Poisson(3.0), 1, Inf)), rand(rng, truncated(Poisson(3.0), 1, Inf)), rand(rng, Gamma(1, 5)), rand(rng, Gamma(2, 5)), 1.0, rand(rng, Exponential(0.1)), rand(rng, Gamma()))),
    "swirling" => (rng, img) -> swirl(img, 0, 10, minimum(size(img)) ÷ 2)
)

deepfry(img; maxdepth=5) = deepfry(default_rng(), img; maxdepth)
nuke(img) = nuke(default_rng(), img)

function deepfry(rng::AbstractRNG, img; maxdepth=5)
    for _ in 1:maxdepth
        name, f = rand(rng, rand(rng, [STRUCTURE_FRYING, COLOR_FRYING]))
        @info "running $name"
        img = f(rng, img)
    end
    img
end

nuke(rng::AbstractRNG, img) = deepfry(rng, img; maxdepth=10)

end
