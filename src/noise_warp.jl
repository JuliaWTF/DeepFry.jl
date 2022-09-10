function noise_warp(img, noise_source; squared=true, variance=0.1)
    h, w = size(img)
    variances = floor.(Int, variance * (squared ? min(h, w) * ones(2) : [h, w]))
    # sampler = opensimplex2_3d()
    # sampler = billow_fractal_3d()
    # sampler=  spheres_3d()
    # sampler = checkered_2d()
    vals = [(Float64.(Gray.(gen_image(noise_source; w, h))) .- 0.5)  for _ in 1:2]
    vecs = [[vals[1][i], vals[2][i]] .* variances for i in CartesianIndices(img)]
    function move_from_vecs(x::SVector{N}) where {N}
        SVector{N}(x .+ vecs[x...])
    end
    img = warp(img, move_from_vecs, axes(img))
    imresize(img[begin+variances[1]:end-variances[1],begin+variances[2]:end-variances[2]], (h, w)) # This crops out given the variances
end

function checker_warp(rng::AbstractRNG, img; squared=true, variance=0.1, scaling=0.1)
    noise_warp(img, CoherentNoise.scale(checkered_2d(seed=rand(rng, UInt)), scaling); squared, variance)
end

function ridged_warp(rng::AbstractRNG, img; squared=true, variance=0.1, frequency=2.5, persistence=0.4, attenuation=1, scaling=0.1)
    source = opensimplex2_3d(seed=rand(rng, UInt))
    source = ridged_fractal_3d(;source, frequency, persistence, attenuation)
    noise_warp(img, CoherentNoise.scale(source, scaling); squared, variance)
end

function cylinder_warp(rng::AbstractRNG, img; squared=true, variance=0.1, frequency=2, scaling=0.1)
    source = cylinders_2d(;seed=rand(rng, UInt), frequency)
    noise_warp(img, CoherentNoise.scale(source, scaling); squared, variance)
end