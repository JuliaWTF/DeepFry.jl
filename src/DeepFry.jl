module DeepFry

using CoherentNoise
using CoherentTransformations
using Colors: Colors, Gray, HSV, RGB, RGBA, mapc
using ColorSchemes: ColorSchemes
# using ColorVectorSpace
using DitherPunk: Bayer, FloydSteinberg, ClusteredDots, dither
using Distributions
using LinearAlgebra
using ImageContrastAdjustment
using ImageFiltering: ImageFiltering, Kernel, imfilter
using ImageTransformations: imresize, warp, center
using JpegTurbo
using JpegGlitcher
using MosaicViews: mosaicview
using OffsetArrays
using OrderedCollections: OrderedDict
using Random: default_rng, AbstractRNG, randexp, GLOBAL_RNG
using StaticArrays
export deepfry, nuke

include("warping.jl")
include("standard_fry.jl")

const prism = ColorSchemes.prism[1:10]
COLOR_FRYING = OrderedDict(
    "It's saturated" =>
        (rng, img) -> begin
            T = eltype(img)
            img = HSV.(img)
            img = HSV.(getfield.(img, :h), rand(rng) * 0.15 + 0.8, getfield.(img, :v))
            T.(img)
        end,
    "Contrast equalizer" =>
        (rng, img) -> adjust_histogram(img, Equalization(; nbins=rand(rng, 2:10))),
    # "color dithering" => (rng, img) -> dither(img, FloydSteinberg(), prism),
)
STRUCTURE_FRYING = OrderedDict(
    "D-D-D-D-Dither" => (rng, img) -> dither(img, Bayer(rand(1:3))),
    "dot clustering" => (rng, img) -> dither(img, ClusteredDots()),
    "Pixie the pixel" => (rng, img) -> begin
        s = size(img)
        imresize(imresize(img; ratio=1 / rand(rng, 4:20)), s)
    end,
    # "Laplacian filtering" =>
        # (rng, img) -> imfilter(img, Kernel.laplacian2d(rand(rng, 0:3))),
    "Gaussian filtering" => (rng, img) -> imfilter(img, Kernel.gaussian(rand(rng, 1:5))),
    "Who the hell is Gabor" =>
        (rng, img) -> imfilter(
            img,
            Kernel.gabor(
                rand(rng, truncated(Poisson(3.0), 1, Inf)),
                rand(rng, truncated(Poisson(3.0), 1, Inf)),
                rand(rng, Gamma(1, 5)),
                rand(rng, Gamma(2, 5)),
                1.0,
                rand(rng, Exponential(0.1)),
                rand(rng, Gamma()),
            ),
        ),
    "Get that swirl" =>
        (rng, img) -> swirl(rng, img, 0, 10, rand(rng, Poisson(minimum(size(img)) ÷ 2))),
    "Bubble like Gauss" => (rng, img) -> bubble(rng, img, rand(rng, Gamma(2.0, 1.0))),
    "Laplace like bubble" => (rng, img) -> sharp_bubble(rng, img, rand(rng, Gamma(1.5, 1.0))),
    "Glitch that itch" => (rng, img) -> glitch(img; rng, n = rand(rng, Poisson(3)) + 1),
    "Chess time" => (rng, img) -> checker_warp(img; rng, variance = rand(rng, Beta()) * 0.5),
    "They say it's ridged" => (rng, img) -> ridged_warp(img; rng),
    "Cows are spherical" => (rng, img) -> sphere_warp(img; rng),
    "Round the cylinder" => (rng, img) -> cylinder_warp(img; rng),
)

FRYING = [STRUCTURE_FRYING, COLOR_FRYING]

function deepfry(img; rng::AbstractRNG=GLOBAL_RNG, madness::Int=5, nostalgia::Bool=false)
    if nostalgia
        img_evol = Matrix{RGB{Float64}}[copy(img)]
    end
    for _ in 1:madness
        name, f = rand(rng, FRYING[rand(rng, Categorical([0.8, 0.2]))])
        @info "$name"
        img = f(rng, img)
        nans = findall(isnan, img)
        if !isempty(nans) # If we got some NaN replace with some color noise
            img[nans] .= rand(rng, eltype(img), length(nans))
        end
        if nostalgia
            push!(img_evol, copy(img))
        end
    end
    if length(unique(img)) < 3
        @info "Your image got completely burned, try again"
    end
    if nostalgia
        display(mosaicview(img_evol; nrow=3))
    end
    return img
end

nuke(img; rng::AbstractRNG=GLOBAL_RNG) = deepfry(img; rng, madness=10, nostalgia=false)

end
