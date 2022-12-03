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
export fry, deepfry, nuke
export COLOR_FRYING, STRUCTURE_FRYING, STD_FRYING, FRYING

include("utils.jl")
include("warping.jl")
include("color_fry.jl")
include("struct_fry.jl")
include("standard_fry.jl")

const prism = ColorSchemes.prism[1:10]
COLOR_FRYING = OrderedDict(
    "It's saturated" => saturate,
    "Contrast equalizer" => equalize_contrast,
    # "color dithering" => (rng, img) -> dither(img, FloydSteinberg(), prism),
)
STRUCTURE_FRYING = OrderedDict(
    "D-D-D-D-Dither" => (rng, img) -> dither(img, Bayer(rand(rng, 1:3))),
    "dot clustering" => (rng, img) -> dither(img, ClusteredDots()),
    "Pixie the pixel" =>
        (rng, img) -> begin
            s = size(img)
            imresize(imresize(img; ratio=1 / rand(rng, 4:20)), s)
        end,
    # "Laplacian filtering" =>
    # (rng, img) -> imfilter(img, Kernel.laplacian2d(rand(rng, 0:3))),
    "Gaussian filtering" =>
        (rng, img) -> imfilter(eltype(img), img, Kernel.gaussian(rand(rng, 1:5))),
    "Who the hell is Gabor" => gabor_filter,
    "Get that swirl" =>
        (rng, img) -> swirl(rng, img, 0, 10, rand(rng, Poisson(minimum(size(img)) ÷ 2))),
    "Bubble like Gauss" => (rng, img) -> bubble(rng, img, rand(rng, Gamma(2.0, 1.0))),
    "Laplace like bubble" =>
        (rng, img) -> sharp_bubble(rng, img, rand(rng, Gamma(1.5, 1.0))),
    "Glitch that itch" => (rng, img) -> glitch(img; rng, n=rand(rng, Poisson(3)) + 1),
    "Chess time" => (rng, img) -> checker_warp(img; rng, variance=rand(rng, Beta()) * 0.5),
    "They say it's ridged" => (rng, img) -> ridged_warp(img; rng),
    "Cows are spherical" => (rng, img) -> sphere_warp(img; rng),
    "Round the cylinder" => (rng, img) -> cylinder_warp(img; rng),
)

FRYING = [STRUCTURE_FRYING, COLOR_FRYING]

"""
    deepfry(
        img::AbstractArray{T, N}; 
        rng::AbstractRNG=GLOBAL_RNG, temperature::Integer=5, nostalgia::Bool=false, verbosity::Integer=0
    )

Take an image and apply a series of random filters to it.

## Keyword arguments

- `rng`: the random number generator seed to pass to the filters.
- `temperature`: (positive) number of layers of filters to apply.
- `nostalgia`: when `true`, save the image after each transformation and display a mosaicview containing each step.
- `verbosity`: control how much information is displayed
    - 0: No output.
    - 1: Print out which frying is used.
    - 2: Print also the timing of each frying and the total frying time.
"""
function deepfry(
    img::AbstractArray{T,N};
    rng::AbstractRNG=GLOBAL_RNG,
    temperature::Integer=5,
    nostalgia::Bool=false,
    verbosity::Integer=0,
) where {T,N}
    0 ≤ verbosity ≤ 2 || error("verbosity should be between 0 and 2.")
    temperature > 0 || error("temperature should be a positive number.")
    if nostalgia && N == 2
        img_evol = Matrix{T}[copy(img)]
    end
    tot_t = @elapsed for _ in 1:temperature
        name, f = rand(rng, FRYING[rand(rng, Categorical([0.8, 0.2]))])
        Base.@logmsg Base.LogLevel(1) "$name"
        t = @elapsed img = f(rng, img)
        Base.@logmsg Base.LogLevel(2) "run in $(t)s"
        nans = findall(isnan, img)
        if !isempty(nans) # If we got some NaN replace with some color noise
            # TODO use the `rng` when `ColorTypes 0.12 is out`
            img[nans] .= rand(eltype(img), length(nans))
        end
        if nostalgia
            push!(img_evol, copy(img))
        end
    end
    if length(unique(img)) < 3
        Base.Base.@logmsg Base.LogLevel(1) "Your image got completely burned, try again"
    end
    Base.@logmsg Base.LogLevel(2) "Total run time: $(tot_t)s"
    if nostalgia
        display(mosaicview(img_evol; nrow=3))
    end
    return img
end

"""
    nuke(img; rng)

Wrapper around [`deepfry`](@ref), forcing a temperature of `10`.
"""
nuke(img; rng::AbstractRNG=GLOBAL_RNG) = deepfry(img; rng, temperature=10, nostalgia=false)

"""
    fry(img; rng)

Frying using a sequence of predetermined layers.
Look at `DeepFry.STD_FRYING` for more details.
"""
function fry(img; rng::AbstractRNG=default_rng())
    return foldl(STD_FRYING; init=img) do img, f
        f(img; rng)
    end
end

end
