module DeepFry

using CoherentNoise
using CoherentTransformations
using Colors: Colors, Gray, HSV, RGB, RGBA, mapc
using ColorSchemes: ColorSchemes
# using ColorVectorSpace
using DitherPunk: Bayer, FloydSteinberg, ClusteredDots, dither
using Distributions
using FileIO
using LinearAlgebra
using ImageContrastAdjustment
using ImageFiltering: ImageFiltering, Kernel, imfilter
using ImageTransformations: imresize, warp, center
using JpegTurbo
using JpegGlitcher
using MosaicViews: mosaicview
using OffsetArrays
using OrderedCollections: OrderedDict
using Random: default_rng, AbstractRNG, randexp, GLOBAL_RNG, Xoshiro
using StaticArrays
export fry, deepfry, nuke, fastfood
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
    "D-D-D-D-Dither" => bayer_dither,
    "dot clustering" => dot_cluster,
    "Pixie the pixel" => pixelize,
    # "Laplacian filtering" =>
    # (rng, img) -> imfilter(img, Kernel.laplacian2d(rand(rng, 0:3))),
    "Gaussian filtering" => gauss_filter,
    "Who the hell is Gabor" => gabor_filter,
    "Get that swirl" => swirl_warp,
    "Bubble like Gauss" => gauss_warp,
    "Laplace like bubble" => laplace_warp,
    "Glitch that itch" => rand_glitch,
    "Chess time" => rand_checker_warp,
    "They say it's ridged" => ridged_warp,
    "Cows are spherical" => sphere_warp,
    "Round the cylinder" => cylinder_warp,
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
    rng::AbstractRNG=default_rng(),
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
        t = @elapsed img = f(img; rng)
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
function nuke(img; rng::AbstractRNG=default_rng())
    return deepfry(img; rng, temperature=10, nostalgia=false)
end

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

"""
    fastfood(name::AbstractString, img::AbstractArray{<:Colorant})

"""
function fastfood(
    name::AbstractString,
    img::AbstractArray,
    n::Integer;
    rng::AbstractRNG=default_rng(),
    temperature::Integer=3,
)
    name = endswith(name, ".gif") ? name : name * ".gif"
    return save(
        name,
        reduce(
            deepfry(
                img;
                rng=Xoshiro(rand(rng, UInt)),
                temperature,
                verbosity=false,
                nostalgia=false,
            ) for _ in 1:n
        ) do x, y
            cat(x, y; dims=3) # Concatenate over the third dimension
        end,
    )
end

end
