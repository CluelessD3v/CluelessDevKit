--[=[
    Perlin noise library of noise functions that includes:
    - Fractal Brownian Motion (FBM) noise: Unlike perlin noise offers a smoother 
    and more organic look and feel

    - Ridge Noise/Turbulence: An extention of FBM which creates sharp ridges instead

    Credit to Sleitnick for the FBM function: https://github.com/Sleitnick/RDC2019-Procedural-Generation
        
]=]

-- stylua: ignore start

local Noise = {}

Noise.FBM = function(x, z, seed, amplitude, frequency, octaves, persistence, lacunarity, gain, scale)
	local result = 0
	for _ = 1, octaves do
		result = (result + (amplitude * math.noise(((x + seed) / frequency) * persistence, ((z + seed) / frequency) * persistence)))
		frequency = (frequency * lacunarity)
		amplitude = (amplitude * gain)
	end

	return result * scale
end

Noise.Turbulence = function(x, z, seed, amplitude, frequency, octaves, persistence, lacunarity, gain, scale)
	local result = 0
	for _ = 1, octaves do
		result += amplitude * math.abs(math.noise(((x + seed) / frequency) * persistence, ((z + seed) / frequency) * persistence))
		frequency = (frequency * lacunarity)
		amplitude = (amplitude * gain)
	end

	return result * scale
end


Noise.Ridge = function(x, z, seed, amplitude, frequency, octaves, persistence, lacunarity, gain, scale)
	local result = 0
	for _ = 1, octaves do
		result += amplitude * math.abs(math.noise(((x + seed) / frequency) * persistence, ((z + seed) / frequency) * persistence))
		frequency = (frequency * lacunarity)
		amplitude = (amplitude * gain)
	end

	result *= scale
	
	result = math.abs(result)
	result = 1 - result
	result *= result

	return result 
end

return Noise
-- stylua: ignore end
