return function (x: number, min: number, max: number, minScale, maxScale: number): number
     x = (x - min)/(max - min) * maxScale
     return math.clamp(x, minScale, maxScale)
 end