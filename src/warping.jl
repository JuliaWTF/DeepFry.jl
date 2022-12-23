# From ImageTransformations example
function swirl(
    img,
    rotation::Real=0.0,
    strength::Real=10.0,
    radius::Real=minimum(size(img)) ÷ 2;
    rng::AbstractRNG = default_rng()
)
    x0 = Tuple(rand(rng, CartesianIndices(img)))

    r = log(2) * radius / 5

    function swirl_map(x::SVector{N}) where {N}
        xd = x .- x0
        ρ = norm(xd)
        θ = atan(reverse(xd)...)

        # Note that `x == x0 .+ ρ .* reverse(sincos(θ))`
        # swirl adds more rotations to θ based on the distance to center point
        θ̃ = θ + rotation + strength * exp(-ρ / r)

        return SVector{N}(x0 .+ ρ .* reverse(sincos(θ̃)))
    end

    return warp(img, swirl_map, axes(img))
end

function bubble(img, factor::Real=1.5; rng::AbstractRNG=default_rng())
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = norm(xd)
        return SVector{N}(x0 .+ exp(-abs2(factor * d / minimum(size(img)))) .* xd)
    end
    return warp(img, bubble_map, axes(img))
end

function vwarp(img, factor::Real=1.5; rng::AbstractRNG=default_rng())
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = first(xd)
        return SVector{N}(
            x0 .+ (exp(-abs2(factor * d / first(size(img)))) * first(xd), last(xd))
        )
    end
    return warp(img, bubble_map, axes(img))
end

function hwarp(img, factor::Real=1.5; rng::AbstractRNG=default_rng())
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = last(xd)
        return SVector{N}(
            x0 .+ (first(xd), exp(-abs(factor * d / last(size(img)))) * last(xd))
        )
    end
    return warp(img, bubble_map, axes(img))
end

function sharp_bubble(img, factor::Real=1.2; rng::AbstractRNG=default_rng())
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = norm(xd)
        return SVector{N}(x0 .+ exp(-abs(factor * d / minimum(size(img)))) .* xd)
    end
    return warp(img, bubble_map, axes(img))
end
