local math_PI = math.PI

function math.Remainder(num) return num - math.Truncate(num) end
function math.Ang(rad) return rad * 180 / math_PI end
function math.Sign(num) return num < 0 and -1 or num == 0 and 0 or num > 0 and 1 end