--[[
		This exists to discourage random idiots from crashing others with malicious sprays.
		I'm aware there are ways around this.
		The point of it isn't a foolproof system.
]]

local sprayex = {}

if not sprayexCache then
	sprayexCache = {}
	sprayexCooldowns = {}
	sprayexCacheDirty = false
end

-- Save the location of active sprays.
if not sprayexInfo then sprayexInfo = {} end

local SPRAYEX_FOLDER = "sprayex"
local SPRAYEX_CACHE_NAME = "cache"

-- When should cached sprays be removed?
local SPRAYEX_CACHE_EXPIRED = 3600 -- An hour.

-- How far should we let people spray from themselves?
local SPRAYEX_RANGE = 128

-- Spray cooldown?
local SPRAYEX_COOLDOWN = 12

function sprayex:CreateDir()
	if not file.Exists(SPRAYEX_FOLDER, "DATA") then file.CreateDir(SPRAYEX_FOLDER) end
end

function sprayex:AddToCache(hex, valid)
	local tab = {creation = os.Time(), valid = valid}
	sprayexCache[hex] = tab
	sprayexCacheDirty = true
end

function sprayex:GetCacheFileLoc() return SPRAYEX_FOLDER .. "/" .. SPRAYEX_CACHE_NAME .. ".txt" end
function sprayex:LoadCache()
	if not file.Exists(self:GetCacheFileLoc(), "DATA") then return end
	local json = file.Read(self:GetCacheFileLoc(), "DATA")
	sprayexCache = util.JSONToTable(json)
end
function sprayex:SaveCache()
	local json = util.TableToJSON(sprayexCache)
	file.Write(SPRAYEX_FOLDER .. "/" .. SPRAYEX_CACHE_NAME .. ".txt", json)
end

function sprayex:PruneCache()
	local shouldSave = false
	local now = os.Time()
	local toRemove = {}
	for hex, info in pairs(sprayexCache) do
		local creationTime = ToNumber(info.creation)
		local age = now - creationTime
		if age < SPRAYEX_CACHE_EXPIRED then continue end

		table.Insert(toRemove, hex)
	end

	for k, hex in pairs(toRemove) do
		sprayexCache[hex] = nil
		shouldSave = true
	end

	return shouldSave
end

function sprayex:GetFlags(data)
	local fileName = util.SHA256(data) .. ".vtf"
	local fileLoc = SPRAYEX_FOLDER .. "/" .. fileName
	file.Write(fileLoc, data)

	-- VTF Flags offset
	local f = file.Open(fileLoc, "rb", "DATA")
	f:Seek(0x14)
	local flags = f:ReadULong() or 0
	f:Close()

	file.Delete(fileLoc)

	return flags
end

function sprayex:ValidData(data)
	local flags = self:GetFlags(data)

	-- mask out malicious flags
	-- Normal Map  | Render Target | Depth Render Target |  No Depth Buffer | SSBump
	local mask = 0x0080 + 0x8000 + 0x10000 + 0x800000 + 0x8000000 + 0x0800
	local maskedFlags = bit.band(mask, flags)

	if maskedFlags > 0 then return false end

	return true
end

function sprayex:CachedHex(hex)
	local info = sprayexCache[hex]
	if not info then return end

	return true
end

function sprayex:ValidHex(hex) return sprayexCache[hex].valid end

function sprayex:PlayerSpray(pl)
	local ct = CurTime()
	if (sprayexCooldowns[pl] or 0) > ct then return end

	local eyepos = pl:EyePos()
	local aimvec = pl:GetAimVector()
	local startPos, endPos = eyepos, eyepos + aimvec * SPRAYEX_RANGE

	local tr = util.TraceLine({start = startPos, endpos = endPos, mask = MASK_SOLID_BRUSHONLY})
	if not tr.Hit then return end

	-- TODO: Double check that player spray path hasn't changed.

	pl:SprayDecal(startPos, endPos)
	pl:EmitSound("SprayCan.Paint")

	sprayexCooldowns[pl] = ct + SPRAYEX_COOLDOWN
	sprayexInfo[pl] = tr.HitPos
end

-- HOOKS, TIMERS, & NETWORKING --

hook.Add("Initialize", "Initialize.sprayex", function()
	sprayex:CreateDir()
	sprayex:LoadCache()
	if sprayex:PruneCache() then sprayex:SaveCache() end
end)

-- Disable default spray functionality.
hook.Add("PlayerSpray", "PlayerSpray.sprayex", function(ply) return true end)

timer.Create("sprayex_save", 12, 0, function()
	if not sprayexCacheDirty then return end
	sprayex:SaveCache()
	sprayexCacheDirty = false
end)

-- Client wants to spray!
net.Receive("sprayex_try", function(len, pl)
	local hex = net.ReadString()

	-- If it's not cached we need to request it be evaluated!
	if not sprayex:CachedHex(hex) then
		handshake.NewToken(pl)

		-- Gives time for the handshake to be passed to the player.
		timer.Simple(0.1, function()
			if not IsValid(pl) then return end
			net.Start("sprayex_evaluate")
			net.Send(pl)
		end)
		return
	end

	-- Client tried to spray something we already know is no good.
	if not sprayex:ValidHex(hex) then return end

	-- We've checked it before, we know it's good!
	sprayex:PlayerSpray(pl)
end)

net.Receive("sprayex_deliver", function(len, pl)
	local token = net.ReadString()

	local valid, hex = net.ReadBool(), net.ReadString()

	-- Hard stop if we fail to sign our token.
	if not pl:SignToken(token) then return end

	-- Spray if it's valid.
	if valid then sprayex:PlayerSpray(pl) end

	-- Add it to the cache.
	sprayex:AddToCache(hex, valid)
end)

util.AddNetworkString("sprayex_listen")
util.AddNetworkString("sprayex_try")
util.AddNetworkString("sprayex_evaluate")
util.AddNetworkString("sprayex_deliver")
util.AddNetworkString("sprayex_updateinfo")