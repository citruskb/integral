local meta_vector = FindMetaTable("Vector")
local VGetNormalized = meta_vector.GetNormalized

local VectorRand = VectorRand

function VectorRandNorm() return VGetNormalized(VectorRand()) end