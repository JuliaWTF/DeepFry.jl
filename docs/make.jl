using Documenter
using DemoCards
using DeepFry
using TestImages

include("generate_examples.jl")
demopage, demo_cb, demo_assets = makedemos("examples"; throw_error=true)

assets = []
isnothing(demo_assets) || (push!(assets, demo_assets))

makedocs(;
    sitename="DeepFry.jl",
    modules=[DeepFry],
    pages=["Home" => "index.md", demopage],
    format=Documenter.HTML(; prettyurls=get(ENV, "CI", nothing) == "true", assets),
)

demo_cb()

deploydocs(; repo="github.com/JuliaWTF/DeepFry.jl.git", push_preview=true)
