function set_brightness(img; rng::AbstractRNG=default_rng(), brightness=rand(rng) .- 0.5)
    map(img) do rgb
        mapc(rgb) do c
            c + brightness
        end
    end
end

function set_contrast(img; rng::AbstractRNG=default_rng(), contrast=randexp(rng))
    img * contrast
end

function sharpen(img; rng::AbstractRNG=default_rng())
    
end

function saturate(img; rng::AbstractRNG=default_rng())

end

function add_noise(img; rng::AbstractRNG=default_rng())

end

function jpeg_compression(img; rng::AbstractRNG=default_rng())
    # YCbCr compression
end