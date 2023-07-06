--[=[
    This is a known as a linear indexing function which allow us to refer to the
    elements of a matrix with a single array
    
    A = [2 6 9; 4 2 8; 3 5 1]
    A =
        2     6     9
        4     2     8
        3     5     1

    matlab link: http://matlab.izmiran.ru/help/techdoc/matlab_prog/ch10_pr9.html

    Stupidly useful when working with matrixes or when you need to map an array
    to a matrix/tensor.
]=]

local function TranslateLinearIndex(index, maxSize)
	local row = math.floor((c - 1) / maxSize) + 1
	local column = (c - 1) % maxSize + 1
	return row, column
end

return TranslateLinearIndex
