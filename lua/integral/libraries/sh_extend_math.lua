local math_PI = math.PI

function math.Remainder(num) return num - math.Truncate(num) end
function math.Ang(rad) return rad * 180 / math_PI end