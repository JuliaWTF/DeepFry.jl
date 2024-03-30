using Documenter
using DemoCards
using DeepFry
using TestImages

include("generate_examples.jl")
demopage, postprocesss_cb, demo_assets = makedemos(
    "examples"; throw_error=true, edit_branch="main"
)

assets = []
isnothing(demo_assets) || (push!(assets, demo_assets))

makedocs(;
    sitename="DeepFry.jl",
    modules=[DeepFry],
    pages=["Home" => "index.md", "Examples" => demopage],
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", nothing) == "true",
        assets,
        size_threshold_warn=200 * 2^10,
        size_threshold=300 * 2^10,
    ),
)

postprocesss_cb()

deploydocs(; repo="github.com/JuliaWTF/DeepFry.jl.git", push_preview=true)
