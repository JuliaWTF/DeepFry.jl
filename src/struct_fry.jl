function bayer_dither(img; rng::AbstractRNG=default_rng())
    return dither(img, Bayer(rand(rng, 1:3)))
end

function dot_cluster(img; rng::AbstractRNG=default_rng())
    return dither(img, ClusteredDots())
end

function pixelize(img; rng::AbstractRNG=default_rng())
    s = size(img)
    return imresize(imresize(img; ratio=1 / rand(rng, 4:20)), s)
end

function gauss_filter(img; rng::AbstractRNG=default_rng())
    return imfilter(eltype(img), img, Kernel.gaussian(rand(rng, 1:5)))
end

function gabor_filter(img::AbstractArray{T}; rng::AbstractRNG=default_rng()) where {T}
    img = imfilter(
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
    )
    return safe_img_convert(T, img)
end

function swirl_warp(img; rng::AbstractRNG=default_rng())
    return swirl(img, 0, 10, rand(rng, Poisson(minimum(size(img)) ÷ 2)); rng)
end

function gauss_warp(img; rng::AbstractRNG=default_rng())
    return bubble(img, rand(rng, Gamma(2.0, 1.0)); rng)
end

function laplace_warp(img; rng::AbstractRNG=default_rng())
    return sharp_bubble(img, rand(rng, Gamma(1.5, 1.0)); rng)
end

function rand_glitch(img; rng::AbstractRNG=default_rng())
    return glitch(img; rng, n=rand(rng, Poisson(3)) + 1)
end

function rand_checker_warp(img; rng::AbstractRNG=default_rng())
    return checker_warp(img; rng, variance=rand(rng, Beta()) * 0.5)
end
