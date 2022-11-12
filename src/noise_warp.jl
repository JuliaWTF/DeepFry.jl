function noise_warp(img, noise_source; squared=true, variance=0.1, crop=true)
    !crop ||
        variance < 0.5 ||
        error(
            "(relative) variance needs to be smaller to 50% (0.5) to avoid cropping the whole image.",
        )
    h, w = size(img)
    variances = floor.(Int, variance * (squared ? min(h, w) * ones(2) : [h, w]))
    vals = [
        (Float64.(Gray.(gen_image(noise_source; w, h))) .- 0.5) * variances[i] for i in 1:2
    ]
    vecs = [[vals[1][i], vals[2][i]] for i in CartesianIndices(img)]
    function move_from_vecs(x::SVector{N}) where {N}
        return SVector{N}(x .+ vecs[x...])
    end
    img = warp(img, move_from_vecs, axes(img))
    return if crop
        imresize(
        img[
            (begin + variances[1]):(end - variances[1]),
            (begin + variances[2]):(end - variances[2]),
        ],
        (h, w),
    ) # This crops out given the variances
    else
        img # This crops out given the variances
    end # This crops out given the variances
end

function checker_warp(
    img; rng::AbstractRNG=default_rng(), squared=true, variance=0.1, scaling=0.1, crop=true
)
    return noise_warp(
        img,
        CoherentNoise.scale(checkered_2d(; seed=rand(rng, UInt)), scaling);
        squared,
        variance,
        crop,
    )
end

function ridged_warp(
    img;
    rng::AbstractRNG=default_rng(),
    squared=true,
    variance=0.1,
    frequency=2.5,
    persistence=0.4,
    attenuation=1,
    scaling=0.1,
    crop=true,
)
    source = opensimplex2_3d(; seed=rand(rng, UInt))
    source = ridged_fractal_3d(; source, frequency, persistence, attenuation)
    display(gen_image(source))
    return noise_warp(img, CoherentNoise.scale(source, scaling); squared, variance, crop)
end

function cylinder_warp(
    img;
    rng::AbstractRNG=default_rng(),
    squared=true,
    variance=0.1,
    frequency=2,
    scaling=0.1,
    crop=true,
)
    source = cylinders_2d(; seed=rand(rng, UInt), frequency)
    return noise_warp(img, CoherentNoise.scale(source, scaling); squared, variance, crop)
end

function sphere_warp(
    img;
    rng::AbstractRNG=default_rng(),
    frequency=100,
    squared=true,
    variance=0.1,
    crop=true,
    scaling=0.1,
)
    source = spheres_3d(; seed=rand(rng, UInt), frequency)
    return noise_warp(img, CoherentNoise.scale(source, scaling); squared, variance, crop)
end
