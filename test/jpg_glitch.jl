using TestImages
using Random: AbstractRNG, MersenneTwister, default_rng
# using DeepFry
# using ImageMagick
# using FileIO
using JpegTurbo
# using DeepFry.JpegTurbo

img = testimage("mountainstream")

# Relevant link for markers  :https://en.wikipedia.org/wiki/JPEG#Syntax_and_structure
no_payload = [
    0x00,
    0xD8,
    (0xD0:0xD7)...,
    0xD9,
]

var_size = [
    0xD8,
    0xC0,
    0xC2,
    0xC4,
    0xDB,
    0xDA,
    (0xE0:0xEF)...,
    0xFE,
]
data = jpeg_encode(img)

#= 
A JPEG image consists of a sequence of segments, each beginning with a marker, each of which begins with a 0xFF byte, followed by a byte indicating what kind of marker it is. Some markers consist of just those two bytes; others are followed by two bytes (high then low), indicating the length of marker-specific payload data that follows. (The length includes the two bytes for the length, but not the two bytes for the marker.) Some markers are followed by entropy-coded data; the length of such a marker does not include the entropy-coded data. Note that consecutive 0xFF bytes are used as fill bytes for padding purposes, although this fill byte padding should only ever take place for markers immediately following entropy-coded scan data (see JPEG specification section B.1.1.2 and E.1.2 for details; specifically "In all cases where markers are appended after the compressed data, optional 0xFF fill bytes may precede the marker").

Within the entropy-coded data, after any 0xFF byte, a 0x00 byte is inserted by the encoder before the next byte, so that there does not appear to be a marker where none is intended, preventing framing errors. Decoders must skip this 0x00 byte. This technique, called byte stuffing (see JPEG specification section F.1.2.3), is only applied to the entropy-coded data, not to marker payload data. Note however that entropy-coded data has a few markers of its own; specifically the Reset markers (0xD0 through 0xD7), which are used to isolate independent chunks of entropy-coded data to allow parallel decoding, and encoders are free to insert these Reset markers at regular intervals (although not all encoders do this).
=#


function glitch(img; rng::AbstractRNG=default_rng(), n=10)
    data = jpeg_encode(img, quality=10)
    valid = Int[]
    i = 1
    while i < length(data)
        if data[i] == 0xFF
            i += 1
            if data[i] ∈ no_payload # Marker not followed by extra bites
                nothing
            elseif data[i] == 0xDD
                i += 4
            elseif data[i] ∈ var_size
                high_byte, low_byte = data[i+1:i+2]
                size = parse(UInt16, bitstring(high_byte) * bitstring(low_byte); base=2)
                i += size
            end
        else
            push!(valid, i)
        end
        i += 1
    end
    for i in 1:n
        loc = rand(rng, valid)
        data[loc] = mod(data[loc]+10, 0xfe)#rand(rng, 0x00:0xfe)
    end
    jpeg_decode(data)
end
glitch(img; n=10000)

glitching = cat([glitch(img; rng=MersenneTwister(56), n=i) for i in 1:100]..., dims=3)
# glitching_vary = cat([glitch(img; rng=MersenneTwister(rand(UInt)), n=5) for i in 1:100]..., dims=3)

# save("test/glitching_2.gif", glitching_vary)
save("test/glitching.gif", glitching)