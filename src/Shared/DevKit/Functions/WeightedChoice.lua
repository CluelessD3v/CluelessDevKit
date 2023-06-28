return function(weights: {[string]: number})
     -- Gets max probability
     local Total = 0
     for _, Probability in pairs(weights) do
         Total += Probability
     end
     
     local Random = math.random(Total)
     local Sum = 0

     for Name,Probability in pairs(weights) do
         Sum += Probability
         if Random <= Sum then
             return Name
         end
     end
end

 
