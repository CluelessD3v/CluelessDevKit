--[=[
    Perlin noise library of noise functions that includes:
    - Fractal Brownian Motion (FBM) noise: Unlike perlin noise offers a smoother 
    and more organic look and feel

    - Ridge Noise/Turbulence: An extention of FBM which creates sharp ridges instead

    Credit to Sleitnick for the FBM function: https://github.com/Sleitnick/RDC2019-Procedural-Generation
        
]=]

local Noise = {}

Noise.FBM = function(x, z, seed, amplitude, frequency, octaves, persistence, lacunarity, gain, scale)
	local result = 0
	for _ = 1, octaves do
		result = (
			result
			+ (amplitude * math.noise(((x + seed) / frequency) * persistence, ((z + seed) / frequency) * persistence))
		)
		frequency = (frequency * lacunarity)
		amplitude = (amplitude * gain)
	end

	return result * scale
end

Noise.Ridge = function(x, z, seed, amplitude, frequency, octaves, persistence, lacunarity, gain, scale)
	local result = 0
	for _ = 1, octaves do
		result = (
			result
			+ (
				amplitude
				* math.abs(math.noise(((x + seed) / frequency) * persistence, ((z + seed) / frequency) * persistence))
			)
		)
		frequency = (frequency * lacunarity)
		amplitude = (amplitude * gain)
		x *= 2
		z *= 2
	end

	return result * scale
end
