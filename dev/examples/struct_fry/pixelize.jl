#! /usr/bin/julia

using TestImages, ImageShow, DeepFry, FileIO
fabio = testimage("fabio")
img = DeepFry.pixelize(fabio)
save("assets/pixelize.png", img); #hide
img #hide

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
