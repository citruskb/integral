local sprayfix = {}

function sprayfix:GetSprayPath() return GetConVar("cl_logofile"):GetString() end

local sprayfixPath = ""
local sprayfixData = ""

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

net.Receive("sprayfix_request", function(len)
	if string.Right(sprayfixPath, 3) ~= "vtf" then return end

	local compressed = util.Compress(sprayfixData)
	if #compressed > 65532 then return end

	net.Start("sprayfix_deliver")
		net.WriteData(compressed)
	net.SendToServer()
end)