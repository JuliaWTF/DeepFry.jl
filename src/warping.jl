# From ImageTransformations example
function swirl(rng::AbstractRNG, img, rotation::Real, strength::Real, radius::Real)
    x0 = Tuple(rand(rng, CartesianIndices(img)))

    r = log(2) * radius / 5

    function swirl_map(x::SVector{N}) where {N}
        xd = x .- x0
        ρ = norm(xd)
        θ = atan(reverse(xd)...)

        # Note that `x == x0 .+ ρ .* reverse(sincos(θ))`
        # swirl adds more rotations to θ based on the distance to center point
        θ̃ = θ + rotation + strength * exp(-ρ / r)

        SVector{N}(x0 .+ ρ .* reverse(sincos(θ̃)))
    end

    warp(img, swirl_map, axes(img))
end


function bubble(rng::AbstractRNG, img, factor::Real = 1.5)
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = norm(xd)
        SVector{N}(x0 .+ exp(-abs2(factor * d / minimum(size(img)))) .* xd)
    end
    warp(img, bubble_map, axes(img))
end

function vwarp(rng::AbstractRNG, img, factor::Real = 1.5)
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = first(xd)
        SVector{N}(x0 .+ (exp(-abs2(factor * d / first(size(img)))) * first(xd), last(xd)))
    end
    warp(img, bubble_map, axes(img))
end

function hwarp(rng::AbstractRNG, img, factor::Real = 1.5)
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = last(xd)
        SVector{N}(x0 .+ (first(xd), exp(-abs(factor * d / last(size(img)))) * last(xd)))
    end
    warp(img, bubble_map, axes(img))
end

function sharp_bubble(rng::AbstractRNG, img, factor::Real = 1.2)
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = norm(xd)
        SVector{N}(x0 .+ exp(-abs(factor * d / minimum(size(img)))) .* xd)
    end
    warp(img, bubble_map, axes(img))
end
