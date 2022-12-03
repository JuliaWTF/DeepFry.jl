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

function sharpen(img; rng::AbstractRNG=default_rng(), scale=rand(rng, Beta(4.0, 20.0)))
    return imfilter(img, ImageFiltering.reflect(SHARPEN_FILTER) * scale)
end

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

function jpeg_compression(
    img; rng::AbstractRNG=default_rng(), quality::Integer=rand(rng, Poisson(15))
)
    0 < quality <= 100 || error("quality needs to be between 0 and 100")
    return jpeg_decode(jpeg_encode(img; quality))
end

const STD_FRYING = [set_brightness, set_contrast, sharpen, add_noise, jpeg_compression]

function fry(img; rng::AbstractRNG=default_rng())
    return foldl(STD_FRYING; init=img) do img, f
        f(img; rng)
    end
end
