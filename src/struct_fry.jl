function gabor_filter(rng::AbstractRNG, img::AbstractArray{T}) where {T}
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
