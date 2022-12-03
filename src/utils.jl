function safe_img_convert(::Type{T}, img::AbstractArray) where {T}
    return map(img) do c
        T(
            mapc(c) do x
                clamp(x, 0, 1)
            end,
        )
    end
end
