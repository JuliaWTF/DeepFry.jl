# From ImageTransformations example
function swirl(
    rng::AbstractRNG,
    img,
    rotation::Real=0.0,
    strength::Real=10.0,
    radius::Real=minimum(size(img)) ÷ 2,
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

function bubble(rng::AbstractRNG, img, factor::Real=1.5)
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = norm(xd)
        return SVector{N}(x0 .+ exp(-abs2(factor * d / minimum(size(img)))) .* xd)
    end
    return warp(img, bubble_map, axes(img))
end

function vwarp(rng::AbstractRNG, img, factor::Real=1.5)
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

function hwarp(rng::AbstractRNG, img, factor::Real=1.5)
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

function sharp_bubble(rng::AbstractRNG, img, factor::Real=1.2)
    x0 = Tuple(rand(rng, CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = norm(xd)
        return SVector{N}(x0 .+ exp(-abs(factor * d / minimum(size(img)))) .* xd)
    end
    return warp(img, bubble_map, axes(img))
end

function random_warp(rng::AbstractRNG, img; variance=0.01, scaling=0.3)
    h, w = size(img)
    variance = floor(Int, variance * min(h, w))
    sampler = opensimplex2_3d()
    # sampler = billow_fractal_3d()
    # sampler=  spheres_3d()
    # sampler = checkered_2d()
    # sampler = opensimplex2_3d()
    sampler = ridged_fractal_3d(;
        source=sampler, frequency=2.5, persistence=0.4, attenuation=1
    )
    sampler = CoherentNoise.scale(sampler, scaling)
    vals = [(Float64.(Gray.(gen_image(sampler; w, h))) .- 0.5) * variance for _ in 1:2]
    vecs = [[vals[1][i], vals[2][i]] for i in CartesianIndices(img)]
    function move_from_vecs(x::SVector{N}) where {N}
        return SVector{N}(x .+ vecs[x...])
    end
    img = warp(img, move_from_vecs, axes(img))
    return imresize(
        img[(begin + variance):(end - variance), (begin + variance):(end - variance)],
        (h, w),
    )
end
