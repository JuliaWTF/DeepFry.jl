"""
    set_brightness(img; rng::AbstractRNG=default_rng(), brightness=rand(rng) * 0.5)

`set_brightness` adds a random brightness to the image. The `brightness` parameter
controls the amount of brightness added to the image.
"""
function set_brightness(
    img::AbstractArray{T}; rng::AbstractRNG=default_rng(), brightness=rand(rng) * 0.5
) where {T}
    return map(img) do rgb
        T(
            mapc(rgb) do c
                clamp(c + brightness, 0, 1)
            end,
        )
    end
end

"""
    set_contrast(img; rng::AbstractRNG=default_rng(), contrast=randexp(rng))

`set_contrast` adds a random contrast to the image. The `contrast` parameter
controls the amount of contrast added to the image.
"""
function set_contrast(
    img::AbstractArray{T}; rng::AbstractRNG=default_rng(), contrast=randexp(rng)
) where {T}
    return map(img) do rgb
        T(
            mapc(rgb) do c
                clamp(c * contrast, 0, 1)
            end,
        )
    end
end

const SHARPEN_FILTER = [
    -2 -2 -2
    -2 32 -2
    -2 -2 -2
]

"""
    sharpen(img; rng::AbstractRNG=default_rng(), scale=rand(rng, Beta(1.0, 20.0))

`sharpen` sharpens the image by convolving it with a sharpening filter. The `scale`
parameter controls the strength of the sharpening.
"""
function sharpen(
    img::AbstractArray{T}; rng::AbstractRNG=default_rng(), scale=rand(rng, Beta(1.0, 20.0))
) where {T}
    img = imfilter(img, ImageFiltering.reflect(SHARPEN_FILTER) * scale)
    return safe_img_convert(T, img)
end

"""
    add_noise(img; rng::AbstractRNG=default_rng(), fill_noise=rand(rng, Beta(3, 10))

`add_noise` adds noise to the image by randomly multiplying some pixel with a random value.
The `fill_noise` parameter controls the probability of a pixel being affected by the noise.
"""
function add_noise(
    img::AbstractArray{T}; rng::AbstractRNG=default_rng(), fill_noise=rand(rng, Beta(3, 10))
) where {T}
    return map(img) do rgb
        if rand(rng, Bernoulli(fill_noise))
            T(
                mapc(rgb, rand(T)) do c1, c2
                    clamp(c1 * c2, 0, 1)
                end,
            )
        else
            rgb
        end
    end
    return img
end

"""
    jpeg_compression(img; rng::AbstractRNG=default_rng(), quality::Integer=rand(rng, Poisson(15))

Compress and decompress the image using the JPEG algorithm. The `quality` parameter
controls the compression level, with higher values resulting in higher quality images.
"""
function jpeg_compression(
    img; rng::AbstractRNG=default_rng(), quality::Integer=rand(rng, Poisson(15))
)
    0 < quality <= 100 || error("quality needs to be between 0 and 100")
    return jpeg_decode(jpeg_encode(img; quality))
end

const STD_FRYING = [
    set_brightness,
    set_contrast,
    sharpen,
    add_noise,
    jpeg_compression,
    (x; rng) -> glitch(x; rng, n=5),
]
