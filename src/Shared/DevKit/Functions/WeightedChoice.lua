local function WeightedChoice(weightsList: { [any]: number })
	local sumOfAllWeights = 0
	for _, weight in weightsList do
		sumOfAllWeights += weight
	end

	local randomNumber = math.random(sumOfAllWeights)
	sumOfAllWeights = 0

	for key, weight in weightsList do
		sumOfAllWeights += weight
		if randomNumber <= sumOfAllWeights then
			return key
		end
	end
end

return WeightedChoice
