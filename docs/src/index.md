# DeepFry.jl

DeepFry.jl is inspired by [deepfried memes](https://knowyourmeme.com/memes/deep-fried-memes).
Its superhero origin story was to automatically deepfry memes.
On the way things happen and it became a chaotic image processing tool.

Every run is entirely random up to the `AbstractRNG` used.


## Showcase
Here are some examples:

```@example show
using TestImages, ImageShow, DeepFry, FileIO
img = testimage("fabio")
deepfry_img = deepfry(img)
save("deepfry-1.png", deepfry_img); # hide
```

![First example of a deepfried image](deepfry-1.png)

```@example show
deepfry_img = deepfry(img)
save("deepfry-2.png", deepfry_img); # hide
```

![Second example of a deepfried image](deepfry-2.png)

### Temperature

You can also adjust the temperature, i.e. how many layers of processing happens:

```@example show
using Random
for i in 1:6
    deepfry_img = deepfry(img, temperature=i)
    save("deepfry-fixed-rng$(i).png", deepfry_img); # hide
end
```

![Example of a deepfried image with fixed RNG](deepfry-fixed-rng1.png)
![Example of a deepfried image with fixed RNG](deepfry-fixed-rng2.png)
![Example of a deepfried image with fixed RNG](deepfry-fixed-rng3.png)
![Example of a deepfried image with fixed RNG](deepfry-fixed-rng4.png)
![Example of a deepfried image with fixed RNG](deepfry-fixed-rng5.png)
![Example of a deepfried image with fixed RNG](deepfry-fixed-rng6.png)

### Animations

There is an integrated function to create a gif with different rendering everytime:

```@example show
fastfood("deepfry.gif", img, 10)
```

![Example of a gif of deepfried images](deepfry.gif)

### Standard deepfrying

If you want something more "classical" there is also a function for that:

```@example show
fry_img = fry(img)
save("fry.png", fry_img); # hide
```

![Example of a fried image](fry.png)

## API

```@autodocs
Modules = [DeepFry]
```
