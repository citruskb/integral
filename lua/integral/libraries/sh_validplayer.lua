-- Validation

-- IsValidPlayer --
local GetMetaTable = GetMetaTable
local meta_pl = FindMetaTable("Player")
function EntityIsPlayer(entity) return GetMetaTable(entity) == meta_pl end
local IsValid = IsValid
function IsValidPlayer(obj) return IsValid(obj) and EntityIsPlayer(obj) end

-- IsValidLivingPlayer --
local PAlive = meta_pl.Alive
hook.Add("InitPostEntity", "InitPostEntity.sh_util.Preload", function() PAlive = meta_pl.Alive end)
hook.Add("OnReloaded", "OnReloaded.sh_util.Preload", function() PAlive = meta_pl.Alive end)
function IsValidLivingPlayer(obj) return IsValidPlayer(obj) and PAlive(obj) end

function AccessorFuncDT(tab, member_name, type, id)
	local meta_ent = FindMetaTable("Entity")
	local setter = meta_ent["SetDT" .. type]
	local getter = meta_ent["GetDT" .. type]

	tab["Set" .. member_name] = function(me, value) setter(me, id, value) end
	tab["Get" .. member_name] = function(me) return getter(me, id) end
end
