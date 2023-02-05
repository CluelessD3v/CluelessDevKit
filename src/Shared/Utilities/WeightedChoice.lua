return function(Example)
     -- Gets max probability
     local Total = 0
     for _, Probability in pairs(Example) do
         Total += Probability
     end
     
     local Random = math.random(Total)
     local Sum = 0

     for Name,Probability in pairs(Example) do
         Sum += Probability
         if Random <= Sum then
             return Name
         end
     end
end

 
