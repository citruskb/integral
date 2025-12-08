local sprayfix = {}

if not sprayfixCache then
	sprayfixCache = {}
	sprayfixCooldowns = {}
	sprayfixCacheDirty = false
end

local SPRAYFIX_FOLDER = "sprayfix"
local SPRAYFIX_CACHE_NAME = "cache"

-- When should cached sprays be removed?
local DAY = 86400
local SPRAYFIX_CACHE_EXPIRED = DAY * 60

-- How far should we let people spray from themselves?
local SPRAYFIX_RANGE = 128
local SPRAYFIX_COOLDOWN = 12

function sprayfix:CreateDir()
	if not file.Exists(SPRAYFIX_FOLDER, "DATA") then file.CreateDir(SPRAYFIX_FOLDER) end
end

function sprayfix:AddToCache(data, valid)
	local tab = {creation = os.Time(), valid = valid}
	sprayfixCache[util.SHA256(data)] = tab
	sprayfixCacheDirty = true
end

function sprayfix:GetCacheFileLoc() return SPRAYFIX_FOLDER .. "/" .. SPRAYFIX_CACHE_NAME .. ".txt" end
function sprayfix:LoadCache()
	if not file.Exists(self:GetCacheFileLoc(), "DATA") then return end
	local json = file.Read(self:GetCacheFileLoc(), "DATA")
	sprayfixCache = util.JSONToTable(json)
end
function sprayfix:SaveCache()
	local json = util.TableToJSON(sprayfixCache)
	file.Write(SPRAYFIX_FOLDER .. "/" .. SPRAYFIX_CACHE_NAME .. ".txt", json)
end

function sprayfix:PruneCache()
	local shouldSave = false
	local now = os.Time()
	local toRemove = {}
	for hash, info in pairs(sprayfixCache) do
		local creationTime = ToNumber(info.creation)
		local age = now - creationTime
		if age < SPRAYFIX_CACHE_EXPIRED then continue end

		table.Insert(toRemove, hash)
	end

	for k, hash in pairs(toRemove) do
		sprayfixCache[hash] = nil
		shouldSave = true
	end

	return shouldSave
end

function sprayfix:GetFlags(data)
	local fileName = util.SHA256(data) .. ".vtf"
	local fileLoc = SPRAYFIX_FOLDER .. "/" .. fileName
	file.Write(fileLoc, data)

	-- VTF Flags offset
	local f = file.Open(fileLoc, "rb", "DATA")
	f:Seek(0x14)
	local flags = f:ReadULong() or 0
	f:Close()

	file.Delete(fileLoc)

	return flags
end

function sprayfix:ValidData(data)
	local flags = self:GetFlags(data)

	-- mask out malicious flags
	-- Normal Map  | Render Target | Depth Render Target |  No Depth Buffer | SSBump
	local mask = 0x0080 + 0x8000 + 0x10000 + 0x800000 + 0x8000000 + 0x0800
	local maskedFlags = bit.band(mask, flags)

	if maskedFlags > 0 then return false end

	return true
end

function sprayfix:CachedHash(hash)
	local info = sprayfixCache[hash]
	if not info then return end

	return true
end

function sprayfix:ValidHash(hash) return sprayfixCache[hash].valid end

function sprayfix:PlayerSpray(pl)
	local ct = CurTime()
	if (sprayfixCooldowns[pl] or 0) > ct then return end

	local eyepos = pl:EyePos()
	local aimvec = pl:GetAimVector()
	local startPos, endPos = eyepos, eyepos + aimvec * SPRAYFIX_RANGE
	if not util.TraceLine({start = startPos, endpos = endPos, mask = MASK_SOLID_BRUSHONLY}).Hit then return end

	pl:SprayDecal(startPos, endPos)
	pl:EmitSound("SprayCan.Paint")
	sprayfixCooldowns[pl] = ct + SPRAYFIX_COOLDOWN
end

-- HOOKS, TIMERS, & NETWORKING --

hook.Add("Initialize", "Initialize.Sprayfix", function()
	sprayfix:CreateDir()
	sprayfix:LoadCache()
	if sprayfix:PruneCache() then sprayfix:SaveCache() end
end)

-- Disable default spray functionality.
hook.Add("PlayerSpray", "PlayerSpray.Sprayfix", function(ply) return true end)

timer.Create("sprayfix_save", 12, 0, function()
	if not sprayfixCacheDirty then return end
	sprayfix:SaveCache()
	sprayfixCacheDirty = false
end)

-- Client wants to spray!
net.Receive("sprayfix_try", function(len, pl)
	local hash = net.ReadString()

	-- If it's not cached we need to request it from them for evaluation!
	if not sprayfix:CachedHash(hash) then
		net.Start("sprayfix_request")
		net.Send(pl)
		return
	end

	-- Client tried to spray something we already know is no good.
	if not sprayfix:ValidHash(hash) then return end

	-- We've checked it before, we know it's good!
	sprayfix:PlayerSpray(pl)
end)

net.Receive("sprayfix_deliver", function(len, pl)
	local data = util.Decompress(net.ReadData(len / 8))

	-- Credits to Ed for this method of checking for malicious sprays.
	local valid = sprayfix:ValidData(data)

	-- Spray if it's valid.
	if valid then sprayfix:PlayerSpray(pl) end

	-- Add it to the cache.
	sprayfix:AddToCache(data, valid)
end)

util.AddNetworkString("sprayfix_try")
util.AddNetworkString("sprayfix_request")
util.AddNetworkString("sprayfix_deliver")