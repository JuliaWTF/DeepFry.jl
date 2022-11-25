using BenchmarkTools
using DeepFry
using DeepFry: COLOR_FRYING, STRUCTURE_FRYING
using Random: default_rng
using Colors
using FixedPointNumbers

Types = (RGB{Float64}, RGB{N0f8}, Gray)
N = 500
rng = default_rng()
SUITE = BenchmarkGroup()
for T in Types
    S = SUITE["$T"] = BenchmarkGroup()
    img = rand(T, N, N)
    COLOR_SUITE = S["Color Layers"] = BenchmarkGroup()
    for (name, layer) in COLOR_FRYING
        COLOR_SUITE[name] = @benchmarkable $(layer)($rng, $img)
    end
    STRUCT_SUITE = S["Struct Layers"] = BenchmarkGroup()
    for (name, layer) in STRUCTURE_FRYING
        STRUCT_SUITE[name] = @benchmarkable $(layer)($rng, $img)
    end
end

run(SUITE)
