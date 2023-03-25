local idCount = 0

return function()
    idCount += 1
    return idCount 
end