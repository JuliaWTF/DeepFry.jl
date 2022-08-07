# From ImageTransformations example
function swirl(img, rotation, strength, radius)
    x0 = Tuple(rand(CartesianIndices(img)))

    r = log(2) * radius /5

    function swirl_map(x::SVector{N}) where N
        xd = x .- x0
        ρ = norm(xd)
        θ = atan(reverse(xd)...)

        # Note that `x == x0 .+ ρ .* reverse(sincos(θ))`
        # swirl adds more rotations to θ based on the distance to center point
        θ̃ = θ + rotation + strength * exp(-ρ/r)

        SVector{N}(x0 .+ ρ .* reverse(sincos(θ̃)))
    end

    warp(img, swirl_map, axes(img))
end


function bubble(img, factor=1.5)
    x0 = Tuple(rand(CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = norm(xd)
        SVector{N}(x0 .+ exp(-abs2(factor * d / minimum(size(img)))) .* xd)
    end
    warp(img, bubble_map, axes(img))
end

function sharp_bubble(img, factor=1.5)
    x0 = Tuple(rand(CartesianIndices(img)))
    function bubble_map(x::SVector{N}) where {N}
        xd = x .- x0
        d = norm(xd)
        SVector{N}(x0 .+ exp(-abs(factor * d / minimum(size(img)))) .* xd)
    end
    warp(img, bubble_map, axes(img))
end