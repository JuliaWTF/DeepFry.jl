folder_to_fn = [
    "color_fry" => DeepFry.COLOR_FRYING,
    "standard_fry" => DeepFry.STD_FRYING,
    "struct_fry" => DeepFry.STRUCTURE_FRYING,
]

for (folder, fns) in folder_to_fn
    mkpath(joinpath(@__DIR__, "examples", folder))
    for fn in fns
        if fn isa Pair
            name, fn = fn
        else
            name = string(nameof(fn))
        end
        open(joinpath(@__DIR__, "examples", folder, string(nameof(fn)) * ".jl"), "w") do io
            println(
                io,
                """
    #! /usr/bin/julia
    # ---
    # title: $(name)
    # cover: assets/$(fn).png
    # id: $(fn)
    # ---
    """,
            )
            println(io, "# # $(name)")
            println(io)
            print(
                io,
                """
      using TestImages, ImageShow, DeepFry, FileIO
      fabio = testimage("fabio")
      img = DeepFry.$(fn)(fabio)
      save("assets/$(fn).png", img); #hide
      img #hide
      """,
            )
        end
    end
end
