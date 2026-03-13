#! /usr/bin/julia

using TestImages, ImageShow, DeepFry, FileIO
fabio = testimage("fabio")
img = DeepFry.laplace_warp(fabio)
save("assets/laplace_warp.png", img); #hide
img #hide

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
