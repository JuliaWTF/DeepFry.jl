for T in (RGB{Float64}, RGB{N0f8}, Gray{Float64})
    for f in (
        saturate,
        equalize_contrast,
        bayer_dither,
        dot_cluster,
        pixelize,
        gauss_filter,
        gabor_filter,
        swirl_warp,
        gauss_warp,
        laplace_warp,
        rand_glitch,
        ridged_warp,
        sphere_warp,
        cylinder_warp,
        set_brightness,
        set_contrast,
        sharpen,
        add_noise,
        jpeg_compression,
    )
        precompile(f, (Matrix{T},))
    end
end
