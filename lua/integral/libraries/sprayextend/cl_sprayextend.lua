local sprayex = {}

function sprayex:GetSprayPath() return GetConVar("cl_logofile"):GetString() end

local sprayexPath = ""
local sprayexData = ""
local sprayexHex = ""

function sprayex:GetFlags()
	-- VTF Flags offset
	local f = file.Open(sprayex:GetSprayPath(), "rb", "MOD")
	f:Seek(0x14)
	local flags = f:ReadULong() or 0
	f:Close()

	return flags
end

function sprayex:ValidData()
	local flags = self:GetFlags()

	-- mask out malicious flags
	-- Normal Map  | Render Target | Depth Render Target |  No Depth Buffer | SSBump
	local mask = 0x0080 + 0x8000 + 0x10000 + 0x800000 + 0x8000000 + 0x0800
	local maskedFlags = bit.band(mask, flags)

	if maskedFlags > 0 then return false end

	return true
end

-- Watch for when we press our spray key.
hook.Add("PlayerBindPress", "PlayerBindPress.sprayex", function(ply, bind)
	if not string.find(bind, "impulse 201") then return end

	if sprayexPath ~= sprayex:GetSprayPath() then
		sprayexPath = sprayex:GetSprayPath()
		sprayexData = file.Read(sprayex:GetSprayPath(), "MOD") or ""
		sprayexHex = scrc32.GetHex(sprayexData)
	end

	net.Start("sprayex_try")
		net.WriteString(sprayexHex)
	net.SendToServer()
end)

net.Receive("sprayex_evaluate", function(len)
	local validity = sprayex:ValidData()

	-- Not a valid filetype.
	if string.Right(sprayexPath, 3) ~= "vtf" then
		validity = false
	end

	-- Exceeds spray limit.
	if #sprayexData > 2 * 1020 * 1024 then
		validity = false
	end

	net.Start("sprayex_deliver")
		net.WriteString(MySelf:GetToken())
		net.WriteBool(validity)
		net.WriteString(sprayexHex)
	net.SendToServer()
end)
