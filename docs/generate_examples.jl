folder_to_fn = [
    "color_fry" => DeepFry.COLOR_FRYING,
    "standard_fry" => DeepFry.STD_FRYING,
    "struct_fry" => DeepFry.STRUCTURE_FRYING,
    "nuggets" => [
        "Nuggets" => DeepFry.nuggets,
        "Nuggets GIF" => (;
            fn = DeepFry.nuggets,
            filename = "nuggets_gif",
            cover = "assets/nuggets_gif.gif",
            body = """
using TestImages, ImageShow, DeepFry, FileIO
fabio = testimage("fabio")
DeepFry.nuggets(fabio; gif_path="assets/nuggets_gif.gif")
load("assets/nuggets_gif.gif") #hide
""",
        ),
    ],
    "fastfood" => [
        "Fast Food" => (;
            fn = DeepFry.fastfood,
            filename = "fastfood",
            cover = "assets/fastfood.gif",
            body = """
using TestImages, ImageShow, DeepFry, FileIO
fabio = testimage("fabio")
DeepFry.fastfood("assets/fastfood.gif", fabio, 5)
load("assets/fastfood.gif") #hide
""",
        ),
    ],
]

for (folder, fns) in folder_to_fn
    folder_path = mkpath(joinpath(@__DIR__, "examples", folder))
    for fn in fns
        if fn isa Pair
            name, fn_val = fn
            if fn_val isa NamedTuple
                fn = fn_val.fn
                filename = fn_val.filename
                cover = fn_val.cover
                body = fn_val.body
            else
                fn = fn_val
                filename = string(nameof(fn))
                cover = "assets/$(filename).png"
                body = nothing
            end
        else
            name = string(nameof(fn))
            filename = string(nameof(fn))
            cover = "assets/$(filename).png"
            body = nothing
        end
        open(joinpath(folder_path, filename * ".jl"), "w") do io
            println(
                io,
                """
#! /usr/bin/julia
# ---
# title: $(name)
# cover: $(cover)
# id: $(folder)_$(filename)
# ---
""",
            )
            println(io, "# # $(name)")
            println(io)
            if isnothing(body)
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
            else
                print(io, body)
            end
        end
    end
end
