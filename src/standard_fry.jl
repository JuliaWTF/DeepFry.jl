function set_brightness(img; rng::AbstractRNG=default_rng(), brightness=rand(rng) * 0.5)
    return map(img) do rgb
        mapc(rgb) do c
            c + brightness
        end
    end
end

function set_contrast(img; rng::AbstractRNG=default_rng(), contrast=randexp(rng))
    return img * contrast
end

const SHARPEN_FILTER = [-2  -2  -2;
                        -2  32  -2;
                        -2  -2  -2]

function sharpen(img; rng::AbstractRNG=default_rng(), scale=rand(rng, Beta(4.0, 20.0)))
    imfilter(img, ImageFiltering.reflect(SHARPEN_FILTER) * scale)
end

function saturate(img; rng::AbstractRNG=default_rng())

end

function add_noise(img; rng::AbstractRNG=default_rng(), fill_noise=0.0)
    for i in eachindex(img)
        img[i] = rand(rng, Bernoulli(fill_noise)) ? img[i] ⊙ rand(eltype(img)) : img[i]
    end
    img
    # return img .⊙ 1.0 #rand(eltype(img), size(img)...)
end

function jpeg_compression(img; rng::AbstractRNG=default_rng(), quality::Integer=10)
    0 < quality <= 100 || error("quality needs to be between 0 and 100")
    return jpeg_decode(jpeg_encode(img; quality))
end

const STD_FRIES = [
    set_brightness,
    set_contrast,
    sharpen,
    add_noise,
    jpeg_compression,
    ]
const N_FRIES = length(STD_FRIES)

# [Distributions.sample(1:n_fries, n_fries; replace=false)]
function standard_fry(img; rng::AbstractRNG=default_rng())
    return foldl(STD_FRIES; init=img) do img, f
        f(img; rng)
    end
end