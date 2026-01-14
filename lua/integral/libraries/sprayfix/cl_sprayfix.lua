local sprayfix = {}

function sprayfix:GetSprayPath() return GetConVar("cl_logofile"):GetString() end

local sprayfixPath = ""
local sprayfixData = ""

function sprayfix:GetFlags()
	-- VTF Flags offset
	local f = file.Open(sprayfix:GetSprayPath(), "rb", "DATA")
	f:Seek(0x14)
	local flags = f:ReadULong() or 0
	f:Close()

	return flags
end

function sprayfix:ValidData()
	local flags = self:GetFlags()

	-- mask out malicious flags
	-- Normal Map  | Render Target | Depth Render Target |  No Depth Buffer | SSBump
	local mask = 0x0080 + 0x8000 + 0x10000 + 0x800000 + 0x8000000 + 0x0800
	local maskedFlags = bit.band(mask, flags)

	if maskedFlags > 0 then return false end

	return true
end

-- Watch for when we press our spray key.
hook.Add("PlayerBindPress", "PlayerBindPress.Sprayfix", function(ply, bind)
	if not string.find(bind, "impulse 201") then return end

	if sprayfixPath ~= sprayfix:GetSprayPath() then
		sprayfixPath = sprayfix:GetSprayPath()
		sprayfixData = file.Read(sprayfix:GetSprayPath(), "MOD") or ""
	end

	local hash = util.SHA256(sprayfixData)
	net.Start("sprayfix_try")
		net.WriteString(hash)
	net.SendToServer()
end)

net.Receive("sprayfix_evaluate", function(len)
	local validity = sprayfix:ValidData()

	-- Not a valid filetype.
	if string.Right(sprayfixPath, 3) ~= "vtf" then
		validity = false
	end

	-- Exceeds spray limit.
	if #sprayfixData > 2 * 1020 * 1024 then
		validity = false
	end

	local hash = util.SHA256(sprayfixData)
	net.Start("sprayfix_deliver")
		net.WriteString(MySelf:GetToken())
		net.WriteBool(validity)
		net.WriteString(hash)
	net.SendToServer()
end)