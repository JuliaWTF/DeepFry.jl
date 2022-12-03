function saturate(rng::AbstractRNG, img::AbstractArray{T}) where {T}
    new_saturation = rand(rng) * 0.15 + 0.8
    map(img) do c
        hsv = HSV(c)
        hsv = HSV(hsv.h, new_saturation, hsv.v)
        T(hsv)
    end
end

function equalize_contrast(rng::AbstractRNG, img)
    return adjust_histogram(img, Equalization(; nbins=rand(rng, 2:10)))
end
