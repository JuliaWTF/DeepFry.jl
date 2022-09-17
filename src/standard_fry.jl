function set_brightness(img; rng::AbstractRNG=default_rng(), brightness=rand(rng) .- 0.5)
    return map(img) do rgb
        mapc(rgb) do c
            c + brightness
        end
    end
end

function set_contrast(img; rng::AbstractRNG=default_rng(), contrast=randexp(rng))
    return img * contrast
end

function sharpen(img; rng::AbstractRNG=default_rng())
    
end

function saturate(img; rng::AbstractRNG=default_rng())

end

function add_noise(img; rng::AbstractRNG=default_rng())
    img .⊙ rand(eltype(img), size(img)...)
end

function jpeg_compression(img; rng::AbstractRNG=default_rng(), quality::Integer=10)
    0 < quality <= 100 || error("quality needs to be between 0 and 1")
    return jpeg_decode(jpeg_encode(img; quality))
end